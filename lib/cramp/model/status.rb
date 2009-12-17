module Cramp
  module Model
    class Status

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
