require 'eventmachine'
EM.epoll

require 'active_support'
require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/kernel/reporting'
require 'active_support/concern'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/buffered_logger'

require 'rack'

module Cramp
  VERSION = '0.10'

  mattr_accessor :logger

  autoload :Action, "cramp/action"
  autoload :Websocket, "cramp/websocket"
  autoload :Body, "cramp/body"
  autoload :PeriodicTimer, "cramp/periodic_timer"
  autoload :KeepConnectionAlive, "cramp/keep_connection_alive"
  autoload :Abstract, "cramp/abstract"
  autoload :Callbacks, "cramp/callbacks"
  autoload :TestCase, "cramp/test_case"
end
