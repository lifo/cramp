$:.unshift File.expand_path(File.join(File.dirname(__FILE__), 'vendor/activesupport/lib'))
require 'active_support'
require 'active_support/concern'
require 'active_support/core_ext/hash/indifferent_access'

$: << File.join(File.dirname(__FILE__), 'vendor/usher/lib')
require 'usher'

module Cramp
  module Controller
    autoload :Base, "cramp/controller/base"
    autoload :Body, "cramp/controller/body"
  end
end
