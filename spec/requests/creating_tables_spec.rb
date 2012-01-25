require 'spec_helper'
describe "Create Table when it doesn't exist yet" do
  # before :each do
  # end
  it "can create a DynamoDB table" do
    # Setup Mocks
    mock_dynamodb_setup
    dynamodb_test.tables.add_mock_table("Test_Counter",double,:active)
    dynamodb_test.tables.add_mock_table("Test_MyTestApp_CreateTest1s",double,:not_present)
    test_table_createtest1=dynamodb_test.tables[:Test_MyTestApp_CreateTest1s]
    # Class
    class CreateTest1 < ActiveDynamoDB::Base
      field :dummy,type: :string
    end
    # Test
    CreateTest1.table_exists?.should be_false
    dynamodb_test.tables.
      should_receive(:create).
      with("Test_MyTestApp_CreateTest1s", 123, 456, {:hash_key=>{"Id"=>:number}})
    CreateTest1.create_table read_capacity: 123, write_capacity: 456, mode: :no_wait
    test_table_createtest1.stub(:status){:active}
    CreateTest1.table_exists?.should be_true
    CreateTest1.table_active?.should be_true
  end
  it "can create the counter table if it doesn't exist during table setup" do
    # Setup Mocks
    mock_dynamodb_setup
    dynamodb_test.tables.add_mock_table("Test_Counter",double,:not_present)
    dynamodb_test.tables.add_mock_table("Test_MyTestApp_CreateTest2s",double,:not_present)
    test_table_createtest2=dynamodb_test.tables[:Test_MyTestApp_CreateTest2s]
    dynamodb_test.tables.
      should_receive(:create).
      with("Test_Counter", 12, 23, {:hash_key=>{:Counter=>:string}})
    dynamodb_test.tables.
      should_receive(:create).
      with("Test_MyTestApp_CreateTest2s", 123, 456, {:hash_key=>{"Id"=>:number}})
    # Class
    class CreateTest2 < ActiveDynamoDB::Base
      field :dummy,type: :string
    end
    # Test
    CreateTest2.table_exists?.should be_false
    CreateTest2.create_table read_capacity: 123, write_capacity: 456, counter_table_read_capacity: 12, counter_table_write_capacity: 23, mode: :no_wait
    test_table_createtest2.stub(:status){:active}
    CreateTest2.table_exists?.should be_true
    CreateTest2.table_active?.should be_true
  end
end
