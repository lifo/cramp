module Cramp
  module Callbacks

    extend ActiveSupport::Concern

    included do
      class_inheritable_accessor :before_start_callbacks, :on_finish_callbacks, :on_start_callback, :on_data_callbacks, :instance_reader => false

      self.before_start_callbacks = []
      self.on_finish_callbacks = []
      self.on_start_callback = []
      self.on_data_callbacks = []
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

      def on_data(*methods)
        self.on_data_callbacks += methods
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

    def _on_data_receive(data)
      data = data.split(/\000([^\377]*)\377/).select{|d| !d.empty? }.collect{|d| d.gsub(/^\x00|\xff$/, '') }
      self.class.on_data_callbacks.each do |callback|
        data.each do |message|
          EM.next_tick { send(callback, message) }
        end
      end
    end

  end
end