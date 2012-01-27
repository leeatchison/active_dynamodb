  #
  #
  # Table Level Interface
  #
  #
module ActiveDynamoDB
  module Table
    #
    # Create the table (and optionally counter_table) if they do not exist
    #
    def create_table options={}
      options[:hash_key]||="Id"
      options[:read_capacity]||=5
      options[:write_capacity]||=5
      options[:counter_table_read_capacity]||=5
      options[:counter_table_write_capacity]||=5
      options[:mode]||=:wait
      options[:table]||=:create_if_not_exist
      options[:counter_table]||=:create_if_not_exist
      if options[:counter_table]==:create_if_not_exist
        raise InvalidCounterTable if dynamodb.tables[counter_table_name].nil?
        ActiveDynamoDB::Logger.log_call self,"dynamodb.tables[#{counter_table_name}].nil?"
        exists=dynamodb.tables[counter_table_name].exists?
        ActiveDynamoDB::Logger.log_call self,"dynamodb.tables[#{counter_table_name}].exists?"
        unless exists
          dynamodb.tables.create(counter_table_name,options[:counter_table_read_capacity],options[:counter_table_write_capacity],hash_key:{:Counter=>:string})
          ActiveDynamoDB::Logger.log_call self,"dynamodb.tables.create(#{counter_table_name},#{options[:counter_table_read_capacity]},#{options[:counter_table_write_capacity]},hash_key:{:Counter=>:string}"
        end
      end
      if options[:table]==:create_if_not_exist
        exists=dynamodb.tables[table_name].exists?
        ActiveDynamoDB::Logger.log_call self,"dynamodb.tables[#{table_name}].exists?"
        unless exists
          dynamodb.tables.create(table_name,options[:read_capacity],options[:write_capacity],hash_key:{options[:hash_key]=>:number})
          ActiveDynamoDB::Logger.log_call self,"dynamodb.tables.create(#{table_name},#{options[:counter_table_read_capacity]},#{options[:counter_table_write_capacity]},hash_key:{:Counter=>:string}"
        end
      end
      if options[:mode]==:wait
        if options[:counter_table]==:create_if_not_exist
            the_table=dynamodb.tables[counter_table_name]
            ActiveDynamoDB::Logger.log_call self,"dynamodb.tables[#{counter_table_name}]"
            status=the_table.status
            ActiveDynamoDB::Logger.log_call self,"dynamodb.tables[#{counter_table_name}].status=#{status.inspect}"
            until status==:active
              sleep 1
              status=the_table.status
              ActiveDynamoDB::Logger.log_call self,"dynamodb.tables[#{counter_table_name}].status=#{status.inspect}"
            end
        end
        if options[:table]==:create_if_not_exist
            the_table=dynamodb.tables[table_name]
            status=the_table.status
            ActiveDynamoDB::Logger.log_call self,"dynamodb.tables[#{table_name}].status=#{status.inspect}"
            until status==:active
              sleep 1
              status=the_table.status
              ActiveDynamoDB::Logger.log_call self,"dynamodb.tables[#{table_name}].status=#{status.inspect}"
            end
        end
      end
      self.table_status
    end


    #
    # Delete the table
    #
    def delete_table
      dynamodb_table.delete
      ActiveDynamoDB::Logger.log_call self,"dynamodb_table.delete"
      @dynamodb_table=nil
      :terminating
    end
    #
    # Return the current read capacity
    #
    def read_capacity_units
      ret=dynamodb_table.read_capacity_units
      ActiveDynamoDB::Logger.log_call self,"dynamodb_table.read_capacity_units=#{ret}"
      ret
    end
    #
    # Return the current write capacity
    #
    def write_capacity_units
      ret=dynamodb_table.write_capacity_units
      ActiveDynamoDB::Logger.log_call self,"dynamodb_table.write_capacity_units=#{ret}"
      ret
    end
    #
    # Set new provisioned capacity
    #
    def provision_capacity read_capacity,write_capacity
      ret=dynamodb_table.provision_throughput read_capacity_units: read_capacity, write_capacity_units: write_capacity
        ActiveDynamoDB::Logger.log_call self,"dynamodb_table.provision_throughput read_capacity_units: #{read_capacity},write_capacity_units: #{write_capacity}"
      ret
    end
    #
    # Return the table status
    # One of: :active, :creating, :termating, :not_present
    #
    def table_status
      ret=dynamodb_table.status
      ActiveDynamoDB::Logger.log_call self,"dynamodb_table.status=#{ret.inspect}"
      ret
    rescue AWS::DynamoDB::Errors::ResourceNotFoundException
      ActiveDynamoDB::Logger.log_call self,"dynamodb_table.status=:not_present"
      return :not_present
    rescue TypeError # The AWS SDK returns this error during the termination process...
      ActiveDynamoDB::Logger.log_call self,"dynamodb_table.status=:terminating"
      return :termating
    end
    #
    # Check to see if the table is active (successfully created)
    #
    def table_active?
      self.table_status==:active
    end
    #
    # Check to see if the table is not present (never created or deleted)
    #
    def table_not_present?
      self.table_status==:not_present
    end
    #
    # Check to see if the table exists (in any state)
    #   (Opposite of table_not_present?)
    #
    def table_exists?
      self.table_status!=:not_present
    end
    #
    # Sleep until the table is present...returns an error if it is not being created
    #
    def wait_until_active
      status=table_status
      return if status==:active
      raise TableNotBeingCreated if status!=:creating
      sleep 1 until table_active?
    end
    #
    # Sleep until the table has been successfully deleted...returns an error if it is not being deleted
    def wait_until_deleted
      status=table_status
      return if status==:not_present
      raise TableNotBeingDeleted if status!=:terminating
      sleep 1 until table_not_present?
    end
  end
  module TableInstance
    #
    # Get the status of the table represented by this table instance.
    #
    def table_status
      self.class.table_status
    end
    #
    # Verify the table associated with this table instance is active.
    #
    def table_active?
      self.class.table_active?
    end
  end
end
