require "rubygems"
require "bundler"

module <%= app_const_base %>
  class Application

    def self.root(path = nil)
      @_root ||= File.expand_path(File.dirname(__FILE__))
      path ? File.join(@_root, path.to_s) : @_root
    end

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
      ActiveRecord::Base.establish_connection(<%= app_const %>.env)<% end %><% if mongoid? %>
      # Initialize Mongoid with the mongoid.yml once EventMachine has started.
      EM::next_tick do
        require 'em-mongo'
        Mongoid.load!(File.join(<%= app_const %>.root, 'config', 'mongoid.yml'))
      end<% end %>
    end

  end
end

Bundler.require(:default, <%= app_const %>.env)

# Preload application classes
Dir['./app/**/*.rb'].each {|f| require f}
