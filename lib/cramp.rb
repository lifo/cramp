require 'eventmachine'
EM.epoll

require 'active_support'
require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/kernel/reporting'
require 'active_support/concern'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/buffered_logger'

module Cramp
  VERSION = '0.10'

  mattr_accessor :logger
end
