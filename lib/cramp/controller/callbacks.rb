module Cramp
  module Controller
    module Callbacks

      extend ActiveSupport::Concern

      ASYNC_RESPONSE = [-1, {}, []].freeze
      DEFAULT_STATUS = 200
      DEFAULT_HEADERS =  { 'Content-Type' => 'text/html' }.freeze

      included do
        class_inheritable_accessor :default_status, :default_headers, :instance_reader => false
        self.default_status = DEFAULT_STATUS
        self.default_headers = DEFAULT_HEADERS

        class_inheritable_accessor :before_start_callbacks, :on_finish_callbacks, :on_start_callback, :instance_reader => false
        self.before_start_callbacks = []
        self.on_finish_callbacks = []
        self.on_start_callback = []
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
          EM.next_tick { send(callback) { before_start(n+1) } }
        else
          continue
        end
      end

      def on_start
        self.class.on_start_callback.each do |callback|
          EM.next_tick { send(callback) }
        end
      end

      def on_finish
        self.class.on_finish_callbacks.each do |callback|
          EM.next_tick { send(callback) }
        end
      end

    end
  end
end