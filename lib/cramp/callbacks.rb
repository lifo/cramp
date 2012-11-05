module Cramp
  module Callbacks

    extend ActiveSupport::Concern

    included do
      class_attribute :before_start_callbacks, :on_finish_callbacks, :on_start_callback, :on_data_callbacks, :instance_reader => false

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
      EM.next_tick do
        begin
          yield
        rescue StandardError, LoadError, SyntaxError => exception
          handle_exception(exception)
        end
      end
    end

    protected

    def _invoke_data_callbacks(message)
      self.class.on_data_callbacks.each do |callback|
        callback_wrapper { send(callback, message) }
      end
    end

    def handle_exception(exception)
      handler = ExceptionHandler.new(@env, exception)

      # Log the exception
      unless ENV['RACK_ENV'] == 'test'
        exception_body = handler.dump_exception
        Cramp.logger ? Cramp.logger.error(exception_body) : $stderr.puts(exception_body)
      end

      case @_state
      when :init
        halt 500, {"Content-Type" => 'text/html'}, ENV['RACK_ENV'] == 'development' ? handler.pretty : 'Something went wrong'
      else
        finish
      end
    end

  end
end
