require "rubygems"
require "bundler"

Bundler.setup
Bundler.require :default, :test

require 'cramp'
require 'test/unit'
require 'http_router'

require 'active_support/buffered_logger'
logger = ActiveSupport::BufferedLogger.new(File.join(File.dirname(__FILE__), "tests.log"))
logger.level = ActiveSupport::BufferedLogger::DEBUG
Cramp.logger = logger
