require 'spec_helper'
class Test1 < ActiveDynamoDB::Base
  field :dummy,type: :string
end
describe "Create Table when it doesn't exist yet" do
  before :each do
    mock_dynamodb_setup
    dynamodb_test.tables.add_mock_table("Test_Counter",double,:active)
    dynamodb_test.tables.add_mock_table("Test_MyTestApp_Test1s",double,:not_present)
    @test_table_test1=dynamodb_test.tables[:Test_MyTestApp_Test1s]
  end
  it "can create a DynamoDB table", :focus do
    Test1.table_exists?.should be_false
    dynamodb_test.tables.
      should_receive(:create).
      with("Test_MyTestApp_Test1s", 123, 456, {:hash_key=>{"Id"=>:number}})
    Test1.create_table read_capacity: 123, write_capacity: 456, mode: :no_wait
    @test_table_test1.stub(:status){:active}
    Test1.table_exists?.should be_true
    Test1.table_active?.should be_true
  end
  it "can create the counter table if it doesn't exist during table setup"
  it "won't create the counter table if it already exists during table setup"
  it "can create a table and wait for it to complete before continuing"
end
