module ActiveDynamoDB
  #
  # Logger for Rails Footnotes
  #
  class Logger
    class<<self
      def enable
        @active_dynamodb_logging_enabled=true
      end
      def log_call obj,data
        return unless @active_dynamodb_logging_enabled
        if @active_dynamodb_call_log.nil?
          @active_dynamodb_call_log=[
            ["Time","Model","Message"]
          ]
        end
        if defined? obj.model_name
          model_name=obj.model_name
        elsif defined? obj.class.model_name
          model_name=obj.class.model_name
        else
          model_name=""
        end
        @active_dynamodb_call_log<<[
          DateTime.now,
          model_name,
          data
        ]
      end
      def any_logs?
        !@active_dynamodb_call_log.nil?
      end
      def log_size
        @active_dynamodb_call_log.size
      end
      def log_array
        @active_dynamodb_call_log
      end
    end
  end
end
