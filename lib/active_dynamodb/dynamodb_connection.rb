module ActiveDynamoDB
  #
  #
  # Connection Management
  #
  #
  module ConnectionInstance
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
  module Connection
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
      # Test Mode
      return @dynamodb=$dynamodb_test if $dynamodb_test
      # Normal Mode
      if @dynamodb.nil?
        @dynamodb=AWS::DynamoDB.new
        ActiveDynamoDB::Logger.log_call self,"Open DynamoDB Connection"
      end
      @dynamodb
    end
    def dynamodb_counter_table
      return @dynamodb_counter_table unless @dynamodb_counter_table.nil?
      the_table=dynamodb.tables[counter_table_name]
      ActiveDynamoDB::Logger.log_call self,"dynamodb.tables[#{table_name}]"
      raise CantFindTable,table_name if the_table.nil?
      the_table.load_schema
      @dynamodb_counter_table=the_table
    end
    def dynamodb_table
      return @dynamodb_table unless @dynamodb_table.nil?
      the_table=dynamodb.tables[table_name]
      ActiveDynamoDB::Logger.log_call self,"dynamodb.tables[#{table_name}]"
      raise CantFindTable,table_name if the_table.nil?
      the_table.load_schema
      @dynamodb_table=the_table
    end
    def counter_hash_key
      ret=dynamodb_counter_table.hash_key.name
      ActiveDynamoDB::Logger.log_call self,"dynamodb_counter_table.hash_key"
      ret
    end
    def hash_key
      ret=dynamodb_table.hash_key.name
      ActiveDynamoDB::Logger.log_call self,"dynamodb_table.hash_key"
      ret
    end
  end
end
