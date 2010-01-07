module Cramp
  module Model
    class Status

      attr_reader :record

      def initialize(record, success)
        @record = record
        @success = success
      end

      def success?
        @success
      end

    end
  end
end
