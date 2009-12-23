# Async MySQL driver for Ruby/EventMachine
#   (c) 2008 Aman Gupta (tmm1)
# http://github.com/tmm1/em-mysql

require 'eventmachine'
require 'fcntl'

class Mysql
  def result
    @cur_result
  end
end

class EventedMysql < EM::Connection
  def initialize mysql, opts
    @mysql = mysql
    @fd = mysql.socket
    @opts = opts
    @current = nil
    @@queue ||= []
    @processing = false
    @connected = true

    log 'mysql connected'

    self.notify_readable = true
    EM.add_timer(0){ next_query }
  end
  attr_reader :processing, :connected, :opts
  alias :settings :opts

  DisconnectErrors = [
    'query: not connected',
    'MySQL server has gone away',
    'Lost connection to MySQL server during query'
  ] unless defined? DisconnectErrors

  def notify_readable
    log 'readable'
    if item = @current
      @current = nil
      start, response, sql, cblk, eblk = item
      log 'mysql response', Time.now-start, sql
      arg = case response
            when :raw
              result = @mysql.get_result
              @mysql.instance_variable_set('@cur_result', result)
              @mysql
            when :select
              ret = []
              result = @mysql.get_result
              result.each_hash{|h| ret << h }
              log 'mysql result', ret
              ret
            when :update
              result = @mysql.get_result
              @mysql.affected_rows
            when :insert
              result = @mysql.get_result
              @mysql.insert_id
            else
              result = @mysql.get_result
              log 'got a result??', result if result
              nil
            end

      @processing = false
      # result.free if result.is_a? Mysql::Result
      next_query
      cblk.call(arg) if cblk
    else
      log 'readable, but nothing queued?! probably an ERROR state'
      return close
    end
  rescue Mysql::Error => e
    log 'mysql error', e.message
    if e.message =~ /Deadlock/
      @@queue << [response, sql, cblk, eblk]
      @processing = false
      next_query
    elsif DisconnectErrors.include? e.message
      @@queue << [response, sql, cblk, eblk]
      return close
    elsif cb = (eblk || @opts[:on_error])
      cb.call(e)
      @processing = false
      next_query
    else
      raise e
    end
  # ensure
  #   res.free if res.is_a? Mysql::Result
  #   @processing = false
  #   next_query
  end

  def unbind
    log 'mysql disconnect', $!
    # cp = EventedMysql.instance_variable_get('@connection_pool') and cp.delete(self)
    @connected = false

    # XXX wait for the next tick until the current fd is removed completely from the reactor
    #
    # XXX in certain cases the new FD# (@mysql.socket) is the same as the old, since FDs are re-used
    # XXX without next_tick in these cases, unbind will get fired on the newly attached signature as well
    #
    # XXX do _NOT_ use EM.next_tick here. if a bunch of sockets disconnect at the same time, we want
    # XXX reconnects to happen after all the unbinds have been processed
    EM.add_timer(0) do
      log 'mysql reconnecting'
      @processing = false
      @mysql = EventedMysql._connect @opts
      @fd = @mysql.socket

      @signature = EM.attach_fd @mysql.socket, true
      EM.set_notify_readable @signature, true
      log 'mysql connected'
      EM.instance_variable_get('@conns')[@signature] = self
      @connected = true
      make_socket_blocking
      next_query
    end
  end

  def execute sql, response = nil, cblk = nil, eblk = nil, &blk
    cblk ||= blk

    begin
      unless @processing or !@connected
        # begin
        #   log 'mysql ping', @mysql.ping
        #   # log 'mysql stat', @mysql.stat
        #   # log 'mysql errno', @mysql.errno
        # rescue
        #   log 'mysql ping failed'
        #   @@queue << [response, sql, blk]
        #   return close
        # end

        @processing = true

        log 'mysql sending', sql
        @mysql.send_query(sql)
      else
        @@queue << [response, sql, cblk, eblk]
        return
      end
    rescue Mysql::Error => e
      log 'mysql error', e.message
      if DisconnectErrors.include? e.message
        @@queue << [response, sql, cblk, eblk]
        return close
      else
        raise e
      end
    end

    log 'queuing', response, sql
    @current = [Time.now, response, sql, cblk, eblk]
  end

  def close
    @connected = false
    fd = detach
    log 'detached fd', fd
  end

  private

  def next_query
    if @connected and !@processing and pending = @@queue.shift
      response, sql, cblk, eblk = pending
      execute(sql, response, cblk, eblk)
    end
  end
  
  def log *args
    return unless @opts[:logging]
    p [Time.now, @fd, (@signature[-4..-1] if @signature), *args]
  end

  public

  def self.connect opts
    unless EM.respond_to?(:watch) and Mysql.method_defined?(:socket)
      raise RuntimeError, 'mysqlplus and EM.watch are required for EventedMysql'
    end

    if conn = _connect(opts)
      EM.watch conn.socket, self, conn, opts
    else
      EM.add_timer(5){ connect opts }
    end
  end

  self::Mysql = ::Mysql unless defined? self::Mysql

  # stolen from sequel
  def self._connect opts
    opts = settings.merge(opts)

    conn = Mysql.init

    # set encoding _before_ connecting
    if charset = opts[:charset] || opts[:encoding]
      conn.options(Mysql::SET_CHARSET_NAME, charset)
    end

    conn.options(Mysql::OPT_LOCAL_INFILE, 'client')

    conn.real_connect(
      opts[:host] || 'localhost',
      opts[:user] || opts[:username] || 'root',
      opts[:password],
      opts[:database],
      opts[:port],
      opts[:socket],
      0 +
      # XXX multi results require multiple callbacks to parse
      # Mysql::CLIENT_MULTI_RESULTS +
      # Mysql::CLIENT_MULTI_STATEMENTS +
      (opts[:compress] == false ? 0 : Mysql::CLIENT_COMPRESS)
    )
    
    # increase timeout so mysql server doesn't disconnect us
    # this is especially bad if we're disconnected while EM.attach is
    # still in progress, because by the time it gets to EM, the FD is
    # no longer valid, and it throws a c++ 'bad file descriptor' error
    # (do not use a timeout of -1 for unlimited, it does not work on mysqld > 5.0.60)
    conn.query("set @@wait_timeout = #{opts[:timeout] || 2592000}")

    # we handle reconnecting (and reattaching the new fd to EM)
    conn.reconnect = false

    # By default, MySQL 'where id is null' selects the last inserted id
    # Turn this off. http://dev.rubyonrails.org/ticket/6778
    conn.query("set SQL_AUTO_IS_NULL=0")

    # get results for queries
    conn.query_with_result = true

    conn
  rescue Mysql::Error => e
    if cb = opts[:on_error]
      cb.call(e)
      nil
    else
      raise e
    end
  end
end

class EventedMysql
  def self.settings
    @settings ||= { :connections => 4, :logging => false }
  end

  def self.execute query, type = nil, cblk = nil, eblk = nil, &blk
    unless nil#connection = connection_pool.find{|c| not c.processing and c.connected }
      @n ||= 0
      connection = connection_pool[@n]
      @n = 0 if (@n+=1) >= connection_pool.size
    end

    connection.execute(query, type, cblk, eblk, &blk)
  end

  %w[ select insert update delete raw ].each do |type| class_eval %[

    def self.#{type} query, cblk = nil, eblk = nil, &blk
      execute query, :#{type}, cblk, eblk, &blk
    end

  ] end

  def self.all query, type = nil, &blk
    responses = 0
    connection_pool.each do |c|
      c.execute(query, type) do
        responses += 1
        blk.call if blk and responses == @connection_pool.size
      end
    end
  end

  def self.connection_pool
    @connection_pool ||= (1..settings[:connections]).map{ EventedMysql.connect(settings) }
    # p ['connpool', settings[:connections], @connection_pool.size]
    # (1..(settings[:connections]-@connection_pool.size)).each do
    #   @connection_pool << EventedMysql.connect(settings)
    # end unless settings[:connections] == @connection_pool.size
    # @connection_pool
  end

  def self.reset_connection_pool!
    @connection_pool = nil
  end
end
