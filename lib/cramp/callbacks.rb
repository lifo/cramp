module Cramp
  module Callbacks

    def self.included(klass)
      klass.class_eval do
        extend ClassMethods

        class_inheritable_accessor :before_start_callbacks, :on_finish_callbacks, :on_start_callback, :instance_reader => false
        
        self.before_start_callbacks = []
        self.on_finish_callbacks = []
        self.on_start_callback = []
      end
    end

    module ClassMethods
      def before_start(*methods)
        self.before_start_callbacks += methods
      end

      def on_finish(*methods)
        self.on_finish_callbacks += methods
      end

      def on_start(*methods)
        self.on_start_callback += methods
      end
    end

    def before_start(n = 0)
      if callback = self.class.before_start_callbacks[n]
        callback_wrapper { send(callback) { before_start(n+1) } }
      else
        continue
      end
    end

    def on_start
      callback_wrapper { start } if respond_to?(:start)

      self.class.on_start_callback.each do |callback|
        callback_wrapper { send(callback) unless @finished }
      end
    end

    def on_finish
      self.class.on_finish_callbacks.each do |callback|
        callback_wrapper { send(callback) }
      end
    end

    def callback_wrapper
      EM.next_tick { yield }
    end

  end
end