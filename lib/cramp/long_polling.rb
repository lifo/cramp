module Cramp
  # All the usual Cramp::Action stuff. But the request is terminated as soon as render() is called.
  class LongPolling < Action
    protected

    def transport
      :long_polling
    end

  end
end
