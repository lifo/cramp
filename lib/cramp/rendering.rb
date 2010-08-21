module Cramp
  module Rendering

    extend ActiveSupport::Concern

    def render(body)
      @body.call(body)
    end

  end
end
