module Cramp
  module Model
    class Relation

      def initialize(klass, relation)
        @klass, @relation = klass, relation
      end

      def each(&block)
        @relation.each do |row|
          object = @klass.instantiate(row)
          block.call(object)
        end
      end

      def all(&block)
        @relation.all do |rows|
          objects = rows.map {|r| @klass.instantiate(r) }
          block.call(objects)
        end
      end

      def first(&block)
        @relation.first do |row|
          object = @klass.instantiate(row)
          block.call(object)
        end
      end

      def select(selects)
        Relation.new(@klass, @relation.project(selects))
      end

      def where(conditions)
        Relation.new(@klass, @relation.where(conditions))
      end

      def select(selects)
        Relation.new(@klass, @relation.project(selects))
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
