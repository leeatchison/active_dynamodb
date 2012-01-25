  class Table
    def initialize table_name
      @name=table_name
    end
    def load_schema
    end
    def status
      :not_present
    end
  end

class DynamoDBTest
  class Tables
    def initialize
      @tables={}
    end
    def [] table_name
      @tables[table_name.to_sym]
    end
    def add_mock_table table_name,mock_obj,initial_status=nil
      mock_obj.stub(:load_schema){nil}
      mock_obj.stub(:status){initial_status} if initial_status
      mock_obj.stub(:exists?){initial_status!=:not_present}
      @tables[table_name.to_sym]=mock_obj
    end
  end
  def tables
    @tables||=Tables.new
  end
end

def dynamodb_test
  $dynamodb_test
end
def mock_dynamodb_setup
  $dynamodb_test=DynamoDBTest.new
end
