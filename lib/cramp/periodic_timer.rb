module Cramp
  module PeriodicTimer

    extend ActiveSupport::Concern

    included do
      class_inheritable_accessor :periodic_timers, :instance_reader => false
      self.periodic_timers ||= []
    end

    module ClassMethods
      def periodic_timer(method, options = {})
        self.periodic_timers << [method, options]
      end
    end

    def initialize(*)
      super
      @timers = []
    end

    protected

    def continue
      super
      start_periodic_timers
    end

    def init_async_body
      super

      if self.class.periodic_timers.any?
        @body.callback { stop_periodic_timers }
        @body.errback { stop_periodic_timers }
      end
    end

    def start_periodic_timers
      self.class.periodic_timers.each do |method, options|
        @timers << EventMachine::PeriodicTimer.new(options[:every] || 1) { timer_method_wrapper(method) unless @finished }
      end
    end

    def stop_periodic_timers
      @timers.each {|t| t.cancel }
    end

    def timer_method_wrapper(method)
      send(method)
    rescue StandardError, LoadError, SyntaxError => exception
      handle_exception(exception)
    end

  end
end
