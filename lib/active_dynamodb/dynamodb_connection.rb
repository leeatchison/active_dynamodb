module ActiveDynamoDB
  class Base
    #
    #
    # Connection Management
    #
    #
    class << self
      #
      # Names (default or configured)
      #
      def table_name
        @dynamodb_table_name||=substitutions("%RailsEnvName%_%AppName%_%PluralModelName%")
      end
      def counter_table_name
        @dynamodb_counter_table_name||=substitutions("%RailsEnvName%_Counter")
      end
      def counter_key_name
        @dynamodb_counter_key_name||=substitutions("%AppName%_%ModelName%")
      end

      #
      # Various connections to DynamoDB
      #
      def dynamodb
        @dynamodb||=AWS::DynamoDB.new
      end
      def dynamodb_counter_table
        return @dynamodb_counter_table unless @dynamodb_counter_table.nil?
        the_table=dynamodb.tables[counter_table_name]
        raise CantFindTable,table_name if the_table.nil?
        the_table.load_schema
        @dynamodb_counter_table=the_table
      end
      def dynamodb_table
        return @dynamodb_table unless @dynamodb_table.nil?
        the_table=dynamodb.tables[table_name]
        raise CantFindTable,table_name if the_table.nil?
        the_table.load_schema
        @dynamodb_table=the_table
      end
      def counter_hash_key
        dynamodb_counter_table.hash_key.name
      end
      def hash_key
        dynamodb_table.hash_key.name
      end
    end

    #
    #
    # Helpers to call class versions...
    #
    #
    def dynamodb
      self.class.dynamodb
    end
    def dynamodb_table
      self.class.dynamodb_table
    end
    def validate_dynamodb
      raise ConnectionNotDefined if dynamodb.nil?
    end
    end
end
