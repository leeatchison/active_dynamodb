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
        unless dynamodb.tables[counter_table_name].exists?
          dynamodb.tables.create(counter_table_name,options[:counter_table_read_capacity],options[:counter_table_write_capacity],hash_key:{:Counter=>:string})
        end
      end
      if options[:table]==:create_if_not_exist
        unless dynamodb.tables[table_name].exists?
          dynamodb.tables.create(table_name,options[:read_capacity],options[:write_capacity],hash_key:{options[:hash_key]=>:number})
        end
      end
      if options[:mode]==:wait
        if options[:counter_table]==:create_if_not_exist
            the_table=dynamodb.tables[counter_table_name]
            sleep 1 until the_table.status==:active
        end
        if options[:table]==:create_if_not_exist
            the_table=dynamodb.tables[table_name]
            sleep 1 until the_table.status==:active
        end
      end
    end


    #
    # Delete the table
    #
    def delete_table
      dynamodb_table.delete
      @dynamodb_table=nil
    end
    #
    # Return the current read capacity
    #
    def read_capacity_units
      dynamodb_table.read_capacity_units
    end
    #
    # Return the current write capacity
    #
    def write_capacity_units
      dynamodb_table.write_capacity_units
    end
    #
    # Set new provisioned capacity
    #
    def provision_capacity read_capacity,write_capacity
      dynamodb_table.provision_throughput read_capacity_units: read_capacity, write_capacity_units: write_capacity
    end
    #
    # Return the table status
    # One of: :active, :creating, :termating, :not_present
    #
    def table_status
      dynamodb_table.status
    rescue AWS::DynamoDB::Errors::ResourceNotFoundException
      return :not_present
    rescue TypeError # The AWS SDK returns this error during the termination process...
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
