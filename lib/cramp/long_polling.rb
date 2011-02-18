module Cramp
  # All the usual Cramp::Action stuff. But the request is terminated as soon as render() is called.
  class LongPolling < Action
    self.transport = :long_polling
  end
end
