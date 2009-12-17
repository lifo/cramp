# Copyright (c) 2009 Koziarski Software Ltd
# 
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

module Cramp
  module Model
    module AttributeMethods

      extend ActiveSupport::Concern
      include ActiveModel::AttributeMethods

      module ClassMethods
        def attribute(name, options = {})
          write_inheritable_hash(:model_attributes, {name => Attribute.new(name, self, options)})
        end

        def define_attribute_methods(force = false)
          return unless model_attributes
          undefine_attribute_methods if force
          super(model_attributes.keys)
        end
      end
  
      included do
        class_inheritable_hash :model_attributes
        undef_method(:id) if method_defined?(:id)

        attribute_method_suffix("", "=")
      end
  
      def write_attribute(name, value)
        if ma = self.class.model_attributes[name.to_sym]
          value = ma.check_value!(value)
        end
        @attributes[name] = value
      end

      def read_attribute(name)
        if ma = self.class.model_attributes[name]
          ma.type_cast(@attributes[name])
        else
          @attributes[name]
        end
      end

      def attributes=(attributes)
        attributes.each do |(name, value)|
          send("#{name}=", value)
        end
      end

      protected

      def attribute_method?(name)
        @attributes.include?(name.to_sym) || model_attributes[name.to_sym]
      end

      private

      def attribute(name)
        read_attribute(name.to_sym)
      end

      def attribute=(name, value)
        write_attribute(name.to_sym, value)
      end

    end
  end
end
