module Cramp
  module Model
    class Engine
      autoload :Connection, "cramp/model/engine/connection"
      
      include Quoting

      def initialize(settings)
        @connection = Connection.new settings
        @quoted_column_names, @quoted_table_names = {}, {}
      end

      def create(relation, &block)
        @connection.insert(relation.to_sql) {|rows| yield(rows) if block_given? }
      end

      def read(relation, &block)
        @connection.select(relation.to_sql) {|rows| yield(rows) }
      end

      def update(relation)
        @connection.update(relation.to_sql) {|rows| yield(rows) if block_given? }
      end

      def delete(relation)
        @connection.delete(relation.to_sql) {|rows| yield(rows) if block_given? }
      end

      def adapter_name
        "mysql"
      end
      
      def connection
        # Arel apparently uses this method to check whether the engine is connected or not
        @connection
      end
      
      def tables
        sql = "SHOW TABLES"
        tables = []
        result = @connection.execute_now(sql)

        result.each { |field| tables << field[0] }
        result.free
        tables
      end

      def columns(table_name, name = nil)
        sql = "SHOW FIELDS FROM #{quote_table_name(table_name)}"
        columns = []
        result = @connection.execute_now(sql)

        result.each { |field| columns << Column.new(field[0], field[4], field[1], field[2] == "YES") }
        result.free
        columns
      end

    end
  end
end
