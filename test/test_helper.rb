require "rubygems"
require "bundler"

Bundler.setup
Bundler.require :default, :test

require 'cramp/controller'
require 'test/unit'
require 'usher'
