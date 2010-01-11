require 'eventmachine'
EM.epoll

require 'active_support'
require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/kernel/reporting'
require 'active_support/concern'

module Cramp
  VERSION = '0.9'
end
