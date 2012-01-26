  #
  #
  # Table Configuration
  #
  #
module ActiveDynamoDB
  module TableConfig
    #
    # Use an existing DynamDB connection...otherwise, it is created on first use.
    #
    def dynamodb= conn
      @dynamodb=conn
    end
    #
    # Name of this table in the DynamoDB service.
    # Substitutions allowed:
    #   %RailsEnvName% - Capitalized name of the current Rails environment
    #   %ModelName% - Name of the model
    #   %AppName% - Name of the Rails App
    # Example:
    #   dynamodb_table_name "%RailsEnvName%_%AppName%_%ModelName%"
    #
    def dynamodb_table_name name
      @dynamodb_table_name=substitutions name
    end
    #
    # Name of the table used for creating index counters.
    # Specifies the name of the table, and the value of the hash_key
    # for this table to use. This item holds an integer that is
    # autonomously incremented on every use. The table/key pair
    # *should* be unique across all apps and all tables used in
    # this AWS account.
    # Substitutions allowed:
    #   %RailsEnvName% - Capitalized name of the current Rails environment
    #   %ModelName% - Name of the model
    #   %AppName% - Name of the Rails App
    # Example:
    #   dynamodb_counter_table_name "%RailsEnvName%_Counter","%AppName%_%ModelName%"
    #
    def dynamodb_counter_table_name table,key
      @dynamodb_counter_table_name=substitutions table
      @dynamodb_counter_key_name=substitutions key
    end

    #
    # Configure a field for the schema
    #
    def field attr_key,options={}
      options[:type]||=:string
      fields[attr_key]=options
    end
    #
    # Setup standard timestamps
    #
    def field_timestamps
      field :created_at,type: :datetime
      field :updated_at,type: :datetime
    end

    #
    # Has Many Association
    #
    def has_many name,options={}
      # TODO: Options to add: select, field_name (similar to foreign_key, but local)
      class_name=options[:class_name]||name.to_s.singularize.capitalize
      attribute_name="#{name}_ids".to_sym
      association_list[name.to_sym]={
        association_name: name,
        attribute_name: attribute_name,
        type: :multiple,
        class_name: class_name,
        klass: Kernel.const_get(class_name),
        dependent: options[:dependent], # LEELEE: TODO
      }
      field attribute_name,type: :set_integers
    end
    #
    # Belongs To Association
    #
    def belongs_to name,options={}
      # TODO: Options to add: select, field_name (similar to foreign_key, but local)
      class_name=options[:class_name]||name.to_s.singularize.capitalize
      attribute_name="#{name}_id".to_sym
      association_list[name.to_sym]={
        association_name: name,
        attribute_name: attribute_name,
        type: :single,
        class_name: options[:class_name]||name.to_s.singularize.capitalize,
        klass:Kernel.const_get(class_name),
        dependent: options[:dependent], # LEELEE: TODO
      }
      field attribute_name,type: :integer
    end

    private

    def substitutions str
      str=
      if defined? Rails
        str.
          gsub(/%RailsEnvName%/,Rails.env.capitalize).
          gsub(/%AppName%/,Rails.application.class.parent_name)
      elsif $dynamodb_test
        str.
          gsub(/%RailsEnvName%/,"Test").
          gsub(/%AppName%/,"MyTestApp")
      else
        str.
          gsub(/%RailsEnvName%/,"NoRailsEnvName").
          gsub(/%AppName%/,"MyApp")
      end
      str.
        gsub(/%ModelName%/,model_name).
        gsub(/%PluralModelName%/,model_name.pluralize)
    end
  end
end
