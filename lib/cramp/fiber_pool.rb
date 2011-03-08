module Cramp
  module FiberPool
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
        
        class_attribute :fiber_pool
      end
    end

    module ClassMethods
      def use_fiber_pool(options = {})
        if RUBY_VERSION < '1.9.1'
          raise "Fibers are supported only for Rubies >= 1.9.1"
        end

        self.fiber_pool = ::FiberPool.new(options[:size] || 100)
        yield self.fiber_pool if block_given?
        include UsesFiberPool
      end
    end

    module UsesFiberPool
      # Overrides wrapper methods to run callbacks in a fiber

      def callback_wrapper
        self.fiber_pool.spawn { yield }
      end

      def timer_method_wrapper(method)
        self.fiber_pool.spawn { send(method) }
      end
    end

  end
end
