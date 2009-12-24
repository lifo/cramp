require 'active_support'
require 'active_support/concern'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/class/inheritable_attributes'
require 'cramp/core_ext'

require 'usher'
require 'rack'

module Cramp
  module Controller
    autoload :Base, "cramp/controller/base"
    autoload :Body, "cramp/controller/body"
    autoload :PeriodicTimer, "cramp/controller/periodic_timer"
    autoload :KeepConnectionAlive, "cramp/controller/keep_connection_alive"
    autoload :Abstract, "cramp/controller/abstract"
    autoload :Callbacks, "cramp/controller/callbacks"
  end
end
