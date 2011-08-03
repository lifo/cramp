require "rubygems"
require "bundler"

Bundler.setup(:default)

require 'cramp'
require 'http_router'
<% if active_record? %>require 'active_record'
<% end %>
# Preload application classes
Dir['./app/**/*.rb'].each {|f| require f}

module <%= app_const_base %>
  class Application

    def self.env
      @_env ||= ENV['RACK_ENV'] || 'development'
    end

    def self.routes
      @_routes ||= eval(File.read('./config/routes.rb'))
    end

    <% if active_record? %>def self.database_config
      @_database_config ||= YAML.load(File.read('./config/database.yml')).with_indifferent_access
    end

    <% end %># Initialize the application
    def self.initialize!<% if active_record? %>
      ActiveRecord::Base.configurations = <%= app_const %>.database_config
      ActiveRecord::Base.establish_connection(<%= app_const %>.env)<% end %>
    end

  end
end
