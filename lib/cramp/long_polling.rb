module Cramp
  # All the usual Cramp::Action stuff. But the request is terminated as soon as render() is called.
  class LongPolling < Action
    self.transport = :long_polling

    protected

    def render(data, *)
      @_lp_headers['Content-Length'] = data.size.to_s

      send_response(@_lp_status, @_lp_headers, @body)
      @body.call(data)

      finish
    end

    def send_initial_response(status, headers, body)
      # Dont send no initial response. Just cache it for later.
      @_lp_status = status
      @_lp_headers = headers
    end

  end
end
