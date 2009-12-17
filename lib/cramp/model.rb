require 'cramp/vendor/evented_mysql'
require 'eventmachine'
require 'mysqlplus'

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), 'vendor/activesupport/lib'))
require 'active_support'
require 'active_support/concern'
require 'active_support/core_ext/hash/indifferent_access'

$: << File.join(File.dirname(__FILE__), 'vendor/arel/lib')
require 'arel'

$: << File.join(File.dirname(__FILE__), 'vendor/activemodel/lib')
require 'active_model'

require 'cramp/model/monkey_patches'
require 'cramp/model/emysql_ext'

module Cramp
  module Model
    autoload :Quoting, "cramp/model/quoting"
    autoload :Engine, "cramp/model/engine"
    autoload :Column, "cramp/model/column"
    autoload :Relation, "cramp/model/relation"

    autoload :Base, "cramp/model/base"
    autoload :Finders, "cramp/model/finders"
    autoload :Attribute, "cramp/model/attribute"
    autoload :AttributeMethods, "cramp/model/attribute_methods"
    autoload :Status, "cramp/model/status"

    def self.init(settings)
      Arel::Table.engine = Cramp::Model::Engine.new(settings)
    end

  end
end

