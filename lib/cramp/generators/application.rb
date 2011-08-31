require 'thor/group'
require 'active_support/core_ext/string/strip'
require 'active_support/inflector/methods'
require 'active_support/core_ext/object/blank'

module Cramp
  module Generators

    class Application < Thor::Group
      include Thor::Actions

      argument :application_path, :type => :string
      class_option :with_active_record, :type => :boolean, :aliases => "-M", :default => false, :desc => "Configures Active Record"
      class_option :with_mongoid, :type => :boolean, :aliases => '-O', :default => false, :desc => 'Configures Mongoid'

      def initialize(*args)
        raise Thor::Error, "No application name supplied. Please run: cramp --help" if args[0].blank?

        super
      end

      def self.source_root
        @_source_root ||= File.join(File.dirname(__FILE__), "templates/application")
      end

      def self.banner
        "cramp new #{self.arguments.map(&:usage).join(' ')} [options]"
      end

      def create_root
        self.destination_root = File.expand_path(application_path, destination_root)
        valid_const?

        empty_directory '.'
        FileUtils.cd(destination_root)
      end

      def create_root_files
        template 'config.ru'
        template 'Gemfile'
        template 'application.rb'

        empty_directory "public"
        empty_directory "public/javascripts"
      end

      def create_config
        empty_directory "config"

        inside "config" do
          template "routes.rb"
          template 'database.yml' if active_record?
          template 'mongoid.yml' if mongoid?
        end
      end

      def create_home_action
        empty_directory "app/actions"

        inside "app/actions" do
          template "home_action.rb"
        end
      end

      def create_models
        if active_record? || mongoid?
          empty_directory "app/models"
        end
      end

      protected

      def active_record?
        options[:with_active_record]
      end

      def mongoid?
        options[:with_mongoid]
      end

      def ruby_19?
        RUBY_VERSION.to_f >= 1.9
      end

      def app_name
        @app_name ||= File.basename(destination_root)
      end

      def app_const
        @app_const ||= "#{app_const_base}::Application"
      end

      def app_const_base
        @app_const_base ||= ActiveSupport::Inflector.camelize(app_name.gsub(/\W/, '_').squeeze('_'), true)
      end

      def valid_const?
        if app_const =~ /^\d/
          raise Thor::Error, "Invalid application name #{app_name}. Please give a name which does not start with numbers."
        elsif Object.const_defined?(app_const_base)
          raise Thor::Error, "Invalid application name #{app_name}, constant #{app_const_base} is already in use. Please choose another application name."
        end
      end
    end

  end
end
