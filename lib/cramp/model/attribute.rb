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
    class Attribute

      FORMATS = {}
      FORMATS[Date]    = /^\d{4}\/\d{2}\/\d{2}$/
      FORMATS[Integer] = /^-?\d+$/
      FORMATS[Float]   = /^-?\d*\.\d*$/
      FORMATS[Time]    = /\A\s*
                -?\d+-\d\d-\d\d
                T
                \d\d:\d\d:\d\d
                (\.\d*)?
                (Z|[+-]\d\d:\d\d)?
                \s*\z/ix # lifted from the implementation of Time.xmlschema

      CONVERTERS = {}
      CONVERTERS[Date] = Proc.new do |str|
        Date.strptime(str, "%Y/%m/%d")
      end

      CONVERTERS[Integer] = Proc.new do |str|
        Integer(str)
      end

      CONVERTERS[Float] = Proc.new do |str|
        Float(str)
      end

      CONVERTERS[Time] = Proc.new do |str|
        Time.xmlschema(str)
      end

      attr_reader :name
      def initialize(name, owner_class, options)
        @name = name.to_s
        @owner_class = owner_class
        @options = options

        # append_validations!
        define_methods!
      end

      # I think this should live somewhere in Amo
      def check_value!(value)
        # Allow nil and Strings to fall back on the validations for typecasting
        # Everything else gets checked with is_a?
        if value.nil?
          nil
        elsif value.is_a?(String)
          value
        elsif value.is_a?(expected_type)
          value
        else
          raise TypeError, "Expected #{expected_type.inspect} but got #{value.inspect}"
        end
      end

      def expected_type
        @options[:type] || String
      end

      def type_cast(value)
        if value.is_a?(expected_type)
          value
        elsif (converter = CONVERTERS[expected_type]) && (value =~ FORMATS[expected_type])
          converter.call(value)
        else
          value
        end
      end

      def append_validations!
        if f = FORMATS[expected_type]
          @owner_class.validates_format_of @name, :with => f, :unless => lambda {|obj| obj.send(name).is_a? expected_type }, :allow_nil => @options[:allow_nil]
        end
      end

      def define_methods!
        @owner_class.define_attribute_methods(true)
      end

      def primary_key?
        @options[:primary_key]
      end

    end

  end
end
