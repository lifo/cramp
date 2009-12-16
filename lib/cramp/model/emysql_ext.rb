class EventedMysql
  def self.execute_now(query)
    @n ||= 0
    connection = connection_pool[@n]
    @n = 0 if (@n+=1) >= connection_pool.size
    connection.execute_now(query)
  end

  def execute_now(sql)
    log 'mysql sending', sql
    @mysql.query(sql)
  rescue Mysql::Error => e
    log 'mysql error', e.message
    if DisconnectErrors.include? e.message
      @@queue << [response, sql, cblk, eblk]
      return close
    else
      raise e
    end
  end
end
