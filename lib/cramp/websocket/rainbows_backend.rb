# :enddoc:
require "rainbows"
class Cramp::Websocket
  # we use autoload since Rainbows::EventMachine::Client should only be
  # loaded in the worker proceses and we want to be preload_app-friendly
  autoload :Rainbows, "cramp/websocket/rainbows"
end
Rainbows::O[:em_client_class] = "Cramp::Websocket::Rainbows"
