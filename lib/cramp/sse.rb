module Cramp
  class SSE < Abstract
    include PeriodicTimer

    def render(data)
      result = "id: #{event_id}\n"
      data.split(/\n/).each {|d| result << "data: #{d}\n" }
      result << "\n"

      @body.call(result)
    end

    def event_id
      @event_id ||= Time.now.to_i
    end

    def respond_with
      [200, {'Content-Type' => 'text/event-stream', 'Cache-Control' => 'no-cache', 'Connection' => 'keep-alive'}]
    end

  end
end
