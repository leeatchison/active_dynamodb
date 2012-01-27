module Footnotes
  module Notes
    class ActiveDynamoDbNote < AbstractNote
      def self.enable
        ActiveDynamoDB::Logger.enable
      end
      # This method always receives a controller
      #
      def initialize(controller)
      end

      # Valid if the log table has been created
      def valid?
        ActiveDynamoDB::Logger.any_logs?
      end

      # Returns the title that represents this note.
      #
      def title
        "ActiveDynamoDB (#{ActiveDynamoDB::Logger.log_size})"
      end

      # The fieldset content
      #
      def content
        mount_table ActiveDynamoDB::Logger.log_array
      end
    end
  end
end
module ActiveDynamoDB
  class << self
    def footnotes_enable
      Footnotes::Notes::ActiveDynamoDbNote.enable
    end
  end
end
