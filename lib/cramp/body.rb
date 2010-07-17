# Copyright 2008 James Tucker <raggi@rubyforge.org>.

module Cramp
  class Body
    include EventMachine::Deferrable

    def initialize
      @queue = []

      # Make sure to flush out the queue before closing the connection
      callback { flush }
    end

    def call(body)
      @queue << body
      schedule_dequeue
    end

    def each &blk
      @body_callback = blk
      schedule_dequeue
    end

    def closed?
      @deferred_status != :unknown
    end

    def flush
      return unless @body_callback

      until @queue.empty?
        Array(@queue.shift).each {|chunk| @body_callback.call(chunk) }
      end
    end

    def schedule_dequeue
      return unless @body_callback

      EventMachine.next_tick do
        next unless body = @queue.shift

        Array(body).each {|chunk| @body_callback.call(chunk) }
        schedule_dequeue unless @queue.empty?
      end
    end

  end
end
