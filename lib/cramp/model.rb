require 'cramp'
require 'cramp/model/evented_mysql'
require 'cramp/model/emysql_ext'

require 'mysqlplus'

require 'arel'
require 'cramp/model/arel_monkey_patches'

require 'active_model'

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

    def self.select(query, callback = nil, &block)
      callback ||= block

      EventedMysql.select(query) do |rows|
        callback.arity == 1 ? callback.call(rows) : callback.call if callback
      end
    end

  end
end

