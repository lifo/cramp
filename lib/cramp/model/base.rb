module Cramp
  module Model
    class Base

      extend Finders
      include AttributeMethods
      include ActiveModel::Validations

      class << self
        def columns
          @columns ||= arel_table.columns
        end

        def column_names
          columns.map(&:name)
        end

        def primary_key
          @primary_key ||= model_attributes.detect {|k, v| v.primary_key? }[0]
        end

        def instantiate(record)
          object = allocate
          object.instance_variable_set("@attributes", record.with_indifferent_access)
          object
        end
      end

      attr_reader :attributes

      def initialize(attributes = {})
        @new_record = true
        @attributes = {}.with_indifferent_access
        self.attributes = attributes
      end

      def new_record?
        @new_record
      end

      def save(callback = nil, &block)
        callback ||= block

        if valid?
          new_record? ? create_record(callback) : update_record(callback)
        else
          callback.arity == 1 ? callback.call(Status.new(self, false)) : callback.call if callback
        end
      end

      private

      def create_record(callback = nil, &block)
        callback ||= block

        self.class.arel_table.insert(arel_attributes(true)) do |new_id|
          if new_id.present?
            self.id = new_id
            saved = true
            @new_record = false
          else
            saved = false
          end

          callback.arity == 1 ? callback.call(Status.new(self, saved)) : callback.call if callback
        end
      end

      def update_record(callback = nil, &block)
        callback ||= block

        relation = self.class.arel_table.where(self.class[self.class.primary_key].eq(send(self.class.primary_key)))

        relation.update(arel_attributes) do |updated_rows|
          callback.arity == 1 ? callback.call(updated_rows) : callback.call if callback
        end
      end

      def arel_attributes(exclude_primary_key = true, attribute_names = @attributes.keys)
        attrs = {}

        attribute_names.each do |name|
          value = read_attribute(name)
          attrs[self.class.arel_table[name]] = value
        end

        attrs
      end

    end
  end
end
