module ActiveDynamoDB
  class Base
    #
    #
    # Save/Delete
    #
    #
    def persisted?
      !@id.nil?
    end
    def save
      return false unless valid?
      internal_save!
      return self
    rescue =>err
      return nil
    end
    def save!
      self.valid?
      raise InvalidAttribute unless valid?
      internal_save!
    end  
    def internal_save!
      run_callbacks :save do
        if persisted?
          run_callbacks :update do
            self.updated_at=DateTime.now unless fields[:updated_at].nil?
            item=dynamodb_table.items[@id]
            raise CouldNotFindItemInDatabase unless item
            item.attributes.update do |u|
              self.changes.each do |key,change|
                # u.set(key=>change[1])
                u.set(key=>attributes[key])
              end
            end
            @previously_changed = changes
            @changed_attributes.clear
          end
        else
          run_callbacks :create do
            now=DateTime.now
            self.created_at=now unless fields[:created_at].nil?
            self.updated_at=now unless fields[:updated_at].nil?
            the_id=self.class.get_next_available_id
            save_data={}
            save_data[self.class.hash_key]=the_id
            self.changes.each do |key,change|
              # save_data[key]=change[1]
              save_data[key]=attributes[key]
            end
            dynamodb_table.items.create save_data
            @id=the_id
            @previously_changed = changes
            @changed_attributes.clear
          end
        end
      end
      self
    end
    def delete
      item=dynamodb_table.items[@id].delete
      attributes={}
      @id=nil
    end
    def destroy
      run_callbacks :destroy do
        # TODO: Add on destroy options in field declaration here...
        item=dynamodb_table.items[@id].delete
        attributes={}
      end
      @id=nil
    end
    class<<self
      #
      #
      # Create aliases...
      #
      #
      def create options=nil
        obj=new options
        obj.save
      end  
      def create! options=nil
        obj=new options
        obj.save!
      end  
      #
      #
      # Get a unique ID for object creation
      #
      #
      def get_next_available_id
        counter_item=dynamodb_counter_table.items[counter_key_name]
        raise InvalidCounterKey if counter_item.nil?
        counter_item.attributes.add({count:1},{return: :updated_new})["count"].to_i
      end
    end
  end
end
