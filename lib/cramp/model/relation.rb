module Cramp
  module Model
    class Relation

      def initialize(klass, relation)
        @klass, @relation = klass, relation
      end

      def each(callback = nil, &block)
        callback ||= block

        @relation.each do |row|
          object = @klass.instantiate(row)
          callback.call(object)
        end
      end

      def all(callback = nil, &block)
        callback ||= block

        @relation.all do |rows|
          objects = rows.map {|r| @klass.instantiate(r) }
          callback.call(objects)
        end
      end

      def first(callback = nil, &block)
        callback ||= block

        @relation.first do |row|
          object = row ? @klass.instantiate(row) : nil
          callback.call(object)
        end
      end

      def where(*conditions)
        Relation.new(@klass, @relation.where(*conditions))
      end

      def select(*selects)
        Relation.new(@klass, @relation.project(*selects))
      end

      def group(groups)
        Relation.new(@klass, @relation.group(groups))
      end

      def order(orders)
        Relation.new(@klass, @relation.order(orders))
      end

      def limit(limits)
        Relation.new(@klass, @relation.take(limits))
      end

      def offset(offsets)
        Relation.new(@klass, @relation.skip(offsets))
      end

    end
  end
end
