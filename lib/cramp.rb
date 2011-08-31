require 'eventmachine'
EM.epoll

require 'active_support'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/kernel/reporting'
require 'active_support/concern'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/except'
require 'active_support/buffered_logger'

require 'rack'

begin
  require 'fiber'
  require File.join(File.dirname(__FILE__), 'vendor/fiber_pool')
rescue LoadError
  # No fibers available!
end
  
module Cramp
  VERSION = '0.15.1'

  mattr_accessor :logger

  autoload :Action, "cramp/action"
  autoload :Websocket, "cramp/websocket"
  autoload :WebsocketExtension, "cramp/websocket/extension"
  autoload :Protocol10FrameParser, "cramp/websocket/protocol10_frame_parser"
  autoload :SSE, "cramp/sse"
  autoload :LongPolling, "cramp/long_polling"
  autoload :Body, "cramp/body"
  autoload :PeriodicTimer, "cramp/periodic_timer"
  autoload :KeepConnectionAlive, "cramp/keep_connection_alive"
  autoload :Abstract, "cramp/abstract"
  autoload :Callbacks, "cramp/callbacks"
  autoload :FiberPool, "cramp/fiber_pool"
  autoload :ExceptionHandler, "cramp/exception_handler"
  autoload :TestCase, "cramp/test_case"

end
