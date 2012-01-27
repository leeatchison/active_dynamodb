#
#
# Query
#
#
module ActiveDynamoDB
  module Query
    def find key
      key=key.to_i
      item=dynamodb_table.items[key]
      ActiveDynamoDB::Logger.log_call self,"dynamodb_table.items[#{key}]"
      return nil unless item and item.exists?
      obj=new
      obj.load_from_item item
    end
  end
  module QueryInstance
    def load_from_item item
      self.attributes={}
      item.attributes.each do |key,value|
        self.attributes[key.to_sym]=value
      end
      @id=item.attributes[self.class.hash_key].to_i
      self
    end
    def initialize attr=nil
      @id=nil
      self.assign_attributes(attr) unless attr.nil?
      fields.each do |field,options|
        send("#{field}=",options[:default]) if send(field).nil? and options[:default]
      end
    end
  end
end
