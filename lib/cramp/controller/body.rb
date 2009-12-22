#  Copyright 2008 James Tucker <raggi@rubyforge.org>.

module Cramp
  module Controller
    class Body

      include EventMachine::Deferrable

      def initialize
        @queue = []
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

      private

      def schedule_dequeue
        return unless @body_callback
        EventMachine.next_tick do
          next unless body = @queue.shift

          body.each{|chunk| @body_callback.call(chunk) }
          schedule_dequeue unless @queue.empty?
        end
      end

    end
  end
end
