require 'active_support/core_ext/module/attribute_accessors'

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
        query = relation.to_sql
        log_query(query)
        EventedMysql.insert(query) {|rows| yield(rows) if block_given? }
      end

      def read(relation, &block)
        query = relation.to_sql
        log_query(query)
        EventedMysql.select(query) {|rows| yield(rows) }
      end

      def update(relation)
        query = relation.to_sql
        log_query(query)
        EventedMysql.update(query) {|rows| yield(rows) if block_given? }
      end

      def delete(relation)
        query = relation.to_sql
        log_query(query)
        EventedMysql.delete(query) {|rows| yield(rows) if block_given? }
      end

      def adapter_name
        "Cramp MySQL Async Adapter"
      end

      def columns(table_name, name = nil)
        sql = "SHOW FIELDS FROM #{quote_table_name(table_name)}"
        columns = []
        result = EventedMysql.execute_now(sql)

        result.each { |field| columns << Column.new(field[0], field[4], field[1], field[2] == "YES") }
        result.free
        columns
      end

      protected

      def log_query(sql)
        Cramp.logger.info("[QUERY] #{sql}") if Cramp.logger
      end
    end
  end
end
