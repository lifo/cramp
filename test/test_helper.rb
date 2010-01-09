require File.join(File.dirname(__FILE__), "../vendor/gems/environment")

cramp_path = File.join(File.dirname(__FILE__), "../lib")
$:.unshift(cramp_path) unless $:.include?(cramp_path)

require 'cramp/controller'
require 'cramp/model'

require 'test/unit'
require 'usher'
