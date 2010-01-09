require 'eventmachine'
EM.epoll

require 'active_support'
require 'active_support/core_ext'
require 'active_support/concern'

require 'cramp/core_ext'

module Cramp
  VERSION = '0.8'
end
