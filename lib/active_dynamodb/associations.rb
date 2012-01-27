#
#
# Associations
#
#
module ActiveDynamoDB
  module Association
    def association_list
      @association_list||={}
    end
  end
  module AssociationInstance
    #
    # Used for has_many associations only...it will scan the included
    # items, and remove any duplicate items or items that the associated
    # related object has been removed...
    #
    def remove_all_stale_associations
      self.class.association_list.each do |name,association|
        remove_stale_associations_from_entry(association)
      end
      self
    end
    def remove_stale_associations association_name
      entry=self.class.association_list[association_name.to_sym]
      raise InvalidAssociation if entry.nil?
      remove_stale_associations_from_entry(entry)
    end
    def remove_stale_associations_from_entry entry
      new_list=[]
      call_association(entry).each do |obj|
        new_list<<obj.id
      end
      send "#{entry[:attribute_name]}=",new_list
    end
    def call_association entry
      if entry[:type]==:multiple
        items=entry[:klass].dynamodb_table.items
        ActiveDynamoDB::Logger.log_call self,"dynamodb_table.items"
        rel=Relation.new(entry[:klass],items,self,entry)
        the_list=self.attributes[entry[:attribute_name].to_sym]
        if the_list.nil? or the_list.size==0
          rel=rel.where(entry[:klass].hash_key).is_null # Should always return an empty set...since everything must have a hash_key
        else
          rel=rel.where(entry[:klass].hash_key).in(*the_list)
        end
        rel
      elsif entry[:type]==:single
        entry[:klass].find self.attributes[entry[:attribute_name].to_sym]
      else
        raise InvalidAssociation
      end
    end
    def assign_association entry,val
      if entry[:type]==:single
        if val.nil?
          self.send("#{entry[:attribute_name]}=",nil)
        else
          self.send("#{entry[:attribute_name]}=",val.id)
        end
      else
        raise InvalidAssociation
      end
    end
  end
end
