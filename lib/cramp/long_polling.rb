module Cramp
  # All the usual Cramp::Action stuff. But the request is terminated as soon as render() is called.
  class LongPolling < Abstract
    include PeriodicTimer
    include KeepConnectionAlive

    def render(data)
      status, headers = respond_with
      headers['Content-Length'] = data.size.to_s

      send_response(status, headers, @body)
      @body.call(data)

      finish
    end

    def send_initial_response(*)
      # Dont send no initial response
    end

  end
end
