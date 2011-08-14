module Cramp
  module FiberPool
    extend ActiveSupport::Concern

    included do
      class_attribute :fiber_pool
    end

    module ClassMethods
      def use_fiber_pool(options = {})
        unless defined?(::FiberPool)
          raise "Fiber support is only available for Rubies >= 1.9.2"
        end

        self.fiber_pool = ::FiberPool.new(options[:size] || 100)
        yield self.fiber_pool if block_given?
        include UsesFiberPool
      end
    end

    module UsesFiberPool
      # Overrides wrapper methods to run callbacks in a fiber

      def callback_wrapper
        self.fiber_pool.spawn do
          begin
            yield
          rescue StandardError, LoadError, SyntaxError => exception
            handle_exception(exception)
          end
        end
      end

      def timer_method_wrapper(method)
        self.fiber_pool.spawn do
          begin
            send(method)
          rescue StandardError, LoadError, SyntaxError => exception
            handle_exception(exception)
          end
        end
      end

    end

  end
end
