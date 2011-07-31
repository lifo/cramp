require "rubygems"
require "bundler"

Bundler.setup(:default)

require 'cramp'
require 'http_router'

require './app/actions/base_action'
require './app/actions/home_action'

module <%= app_const_base %>
  class Application

    def self.routes
      @_routes ||= eval(File.read('./config/routes.rb'))
    end

  end
end
