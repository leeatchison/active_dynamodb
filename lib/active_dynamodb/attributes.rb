module ActiveDynamoDB
  module AttributeInstance
    #
    #
    # Attributes Management
    #
    #
    def id
      @id
    end
    #
    # Return all attributes
    #
    def attributes
      @attributes||={}
    end
    #
    # Assign all mass assignable attributes
    #
    def attributes= attrs
      self.assign_attributes(attrs)
    end
    def update_attributes attrs
      self.assign_attributes(attrs)
      self.save
    end
    def update_attributes! attrs
      self.assign_attributes(attrs)
      self.save!
    end
    #
    # Assign all mass assignable attributes
    #
    def assign_attributes(attributes, options = {})
      return unless attributes
      unless options[:without_protection]
        attributes = sanitize_for_mass_assignment(attributes, options[:as] || :default)
      end
      attributes.each do |k, v|
        if fields.include?(k.to_sym) or respond_to?("#{k}=")
          send("#{k}=", v)
        else
          raise(UnknownAttributeError, "unknown attribute: #{k}")
        end
      end
    end
    def method_missing(id, *args)
      #
      # Create a Relation object when an association method is called
      return call_association(self.class.association_list[id.to_sym]) if self.class.association_list[id.to_sym]
      #
      # Handle assigning belongs_to...
      return assign_association(self.class.association_list[id[0..-2].to_sym],args[0]) if self.class.association_list[id[0..-2].to_sym]
      #
      # Fields...
      fields.each do |field,options|
        if id==field
          return self.class.to_attr_type(field,attributes[field])
        end
        if id.to_s=="#{field}="
          new_value=self.class.to_dynamodb_type field,args[0]
          attribute_will_change!(field) unless new_value == attributes[field]
          attributes[field]=new_value
          return args[0]
        end
      end
      super
    end
    #
    #
    # Field Management
    #
    #
    def fields
      self.class.fields
    end
  end
  module Attribute
    def fields
      @fields||={}
    end
    # TODO: Should we store the value in the "used" format, and only change on persist, rather than store in the persisted format? Will save on object duping...
    def to_dynamodb_type key,value
      return nil if value.nil?
      ret=case self.fields[key.to_sym][:type]
      when :string then value.to_s
      when :symbol then value.to_s
      when :integer then value.to_i
      when :set_integers then value.map{|a|a.to_i}.to_a
      when :set_strings then value.map{|a|a.to_s}.to_a
      when :datetime then (value=="") ? nil : value.to_datetime.utc.to_s
      when :date then (value=="") ? nil : value.to_date.to_s
      else
        raise InvalidAttributeType
      end
      ret
    end
    def to_attr_type key,value
      raise InvalidField,"Unknown field: #{key}" if fields[key].nil?
      return nil if value.nil?
      ret=case self.fields[key.to_sym][:type]
        when :string then value.to_s
        when :symbol then value.to_sym
        when :integer then value.to_i
        when :set_integers then value.to_a.map{|a|a.to_i}
        when :set_strings then value.to_a.map{|a|a.to_s}
        when :datetime then value.to_datetime
        when :date then value.to_date
        else
          raise InvalidAttributeType,"Invalid type: #{self.fields[key.to_sym][:type].inspect}"
      end
      ret
    end
  end
end
