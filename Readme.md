# Active DynamoDB
This gem is a Rails ActiveModel implementation of an ORB for
Amazon AWS's DynamoDB service.

# THIS IS A WORK IN PROGRESS
It is not yet ready to be used by others. However, suggestions for
improvements, pulls, and bug reports are all appreciated.

Thanks!

# Tests
I am still trying to figure out the best way to test with DynamoDB. While
I could stub or mock, I want to look into ways to QA with the live DynamoDB
service, but test-mode tables... This is still a work in progress...



# Documentation In Progress...

# Install/Setup

# Basic Model Configuration

An ActiveDynamicDB model must be setup as follows:

  class MyModel << ActiveDynamoDB::Base
    field :myfield, type: :integer
    ...
  end

Each field in your table must be configured using the 'field' command.

  field <attribute_name>,<options_hash>

The first parameter is a symbol referring to the name of this field,
the second parameter is a hash of options. The following options are valid:

  :type - The data type of the attribute. This can be one of the following values:
    :type => :string - The field represents a string.
    :type => :integer - The field represents an integer.
    :type => :symbol - The field represents a Ruby symbol.
    :type => :set_integers - The field represents a set of integers.
    :type => :set_strings - The field represents a set of strings.
    :type => :datetime - The field represents a value of type DateTime.
  :default - The default value for this attribute
  :class_name - Name of the assoicated class

Additionally, a table may specify the following special field:

  class MyModel << ActiveDynamoDB::Base
    field ...

    field_timestamps # <<== Add :created_at and :updated_at fields
  end

The field_timestamps adds the :created_at and :updated_at fields, and
sets the type of both to :datetime. These values will be automatically
filled in when records are created and updated.

## Table Naming

The name of the table that corresponds to a value is automatically
created using the Rails environment, application name, and model name.
You can override this default table name using the following:

  class MyModel << ActiveDynamoDB::Base
    dynamodb_table_name "MyModelTableName"


  end

This can be a simple string, or it can have any of the following
variables, which will be automatically substituted when creating
the model name:

  %RailsEnvName% - The name of the Rails environemnt (capitalized)
  %AppName% - The name of this applicaiton
  %ModelName% - The name of this model.

The default name of a table is:

  "%RailsEnvName%_%AppName%_%ModelName%"

## Counter Table

xxx


# Creating Table and Managing Tables
Before you can use these models, you must create the table within
ActiveDB. You can do this by the following command:

  MyModel.create_table

This command will create the corresponding table in ActiveDB, set
default read/write table capacity, and will wait until the table
is created and active before it returns. Additionally, a shared
"Counter" table must be created that is used for managing unique
index values for all tables in your account. If this table does
not exist, it is automatically created the first time you
create a table for your application using the create_table call.

When you call create_table, you can pass a hash of options that
provide specific values. Here is an example:

  MyModel.create_table read_capcity: 5, write_capacity: 5

Here are all the options that are supported by create_table:

  hash_key (default "Id"). This value specifies the primary key
    used by this table.
  read_capacity (default 5). This value specifies the reserved
    read capacity for this table (see DynamoDB documentation for details)
  write_capacity (default 5). This value specifies the reserved
    write capacity for this table (see DynamoDB documentation for details)
  counter_table_read_capacity (default 5). This value specifies the reserved
    read capacity for the counter table, if the create_table call needs
    to create this table.
  counter_table_write_capacity (default 5). This value specifies the reserved
    write capacity for the counter table, if the create_table call needs
    to create this table.
  mode (default :wait). If :wait, then this call will not return until the
    DynamoDB table has been created and is active. Passing :no_wait will cause
    this call to return immediately and allow the table creation to go on
    asynchronously.
  counter_table (default :create_if_not_exist). If set to the default value,
    then the counter table is created if the counter table does not yet exist.

If you are done with a table, you can delete it using:

  MyModel.delete_table

This will delete the table for the corresponding model. Note, this will
also delete all data within this table, with no possible way to restore the data.

To view provisioned capacity for a model, use the following commands:

  MyModel.read_capacity_units # -> Returns reserved read capacity for the corresponding DynamoDB table.
  MyModel.write_capacity_units # -> Returns reserved write capacity for the corresponding DynamoDB table.

To change the provisioned capacity for a model, use the following command:

  MyModel.provision capcity 25,50

This will reserve 25 units of read capacity and 50 units of write capacity.

To check the status of a table, you can use:

  MyModel.table_status

This will return one of the following values:

  :active - Table is active and available.
  :creating - Table is being created.
  :terminating - Table is being deleted.
  :not_present - Table does not exist (either deleted or never have been created).

There are also several shortcuts available for table status:

  MyModel.table_active? - Returns true if table_status is :active
  MyModel.table_not_present? - Returns true if table_status is :not_present
  MyModel.table_exists? - Returns true if the table_status is *not* :not_present

You can also wait for a table to be created or deleted:

  MyModel.wait_until_active - Waits until table status is :active
  MyModel.wait_until_deleted - Waits until table status is :not_present



