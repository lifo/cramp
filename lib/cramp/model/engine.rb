module Cramp
  module Model
    class Engine
      include Quoting

      def initialize(settings)
        @settings = settings
        @quoted_column_names, @quoted_table_names = {}, {}
        EventedMysql.settings.update(settings)
      end

      def create(relation, &block)
        EventedMysql.insert(relation.to_sql) {|rows| yield(rows) if block_given? }
      end

      def read(relation, &block)
        EventedMysql.select(relation.to_sql) {|rows| yield(rows) }
      end

      def update(relation)
        EventedMysql.update(relation.to_sql) {|rows| yield(rows) if block_given? }
      end

      def delete(relation)
        EventedMysql.delete(relation.to_sql) {|rows| yield(rows) if block_given? }
      end

      def adapter_name
        "mysql"
      end
      
      def connection
        # Arel apparently uses this method to check whether the engine is connected or not
        true
      end
      
      def tables
        sql = "SHOW TABLES"
        tables = []
        result = EventedMysql.execute_now(sql)

        result.each { |field| tables << field[0] }
        result.free
        tables
      end

      def columns(table_name, name = nil)
        sql = "SHOW FIELDS FROM #{quote_table_name(table_name)}"
        columns = []
        result = EventedMysql.execute_now(sql)

        result.each { |field| columns << Column.new(field[0], field[4], field[1], field[2] == "YES") }
        result.free
        columns
      end

    end
  end
end
