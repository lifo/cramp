module Cramp
  module Model
    module Finders

      def all
        Relation.new(self, arel_table)
      end

      def first(&block)
        Relation.new(self, arel_table).limit(1).each(&block)
      end

      def where(relation)
        Relation.new(self, arel_table.where(relation))
      end

      def [](attribute)
        arel_table[attribute]
      end

      def arel_table
        @arel_table ||= Arel::Table.new(table_name)
      end

      private

      def table_name
        @table_name || self.to_s.pluralize
      end

    end
  end
end
