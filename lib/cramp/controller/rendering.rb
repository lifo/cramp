module Cramp
  module Controller
    module Rendering

      extend ActiveSupport::Concern

      def render(body)
        @body.call(body)
      end

    end
  end
end
