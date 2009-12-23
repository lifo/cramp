module Cramp
  module Controller
    module BeforeStart
      extend ActiveSupport::Concern

      module ClassMethods
        def before_start(*methods)
          @before_start = methods
        end

        def before_start_callbacks
          @before_start || []
        end
      end

      def process
        EM.next_tick { before_start }
        super
      end

      def before_start(n = 0)
        if callback = self.class.before_start_callbacks[n]
          send(callback) { before_start(n+1) }
        else
          continue
        end
      end

    end
  end
end
