require "rubygems"
require "bundler"

gem 'minitest'
require "minitest/autorun"

Bundler.setup
Bundler.require :default, :test

require 'cramp'
require 'http_router'
ActiveSupport.test_order = :sorted

require 'logger'
logger = Logger.new(File.join(File.dirname(__FILE__), "tests.log"))
logger.level = Logger::DEBUG
Cramp.logger = logger
