module Cramp
  module Controller
    module PeriodicTimer

      extend ActiveSupport::Concern

      module ClassMethods
        def periodic_timer(method, options = {})
          @periodic_timers ||= []
          @periodic_timers << [method, options]
        end

        def periodic_timers
          defined?(@periodic_timers) ? @periodic_timers : []
        end
      end

      def initialize(*)
        super
        @timers = []
      end

      def continue
        super
        EM.next_tick { start_periodic_timers }
      end

      def init_async_body
        super
        @body.callback { stop_periodic_timers }
        @body.errback { stop_periodic_timers }
      end

      private

      def start_periodic_timers
        self.class.periodic_timers.each do |method, options|
          @timers << EventMachine::PeriodicTimer.new(options[:every] || 1) { send(method) }
        end
      end

      def stop_periodic_timers
        @timers.each {|t| t.cancel }
      end

    end
  end
end
