module ActiveDynamoDB
  class Base
    #
    # Active Model
    #
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Dirty
    extend ActiveModel::Callbacks

    define_model_callbacks :create, :update, :save, :destroy, :validation

    include ActiveDynamoDB::ConnectionInstance
    include ActiveDynamoDB::TableInstance
    include ActiveDynamoDB::PersistenceInstance
    include ActiveDynamoDB::QueryInstance
    include ActiveDynamoDB::AssociationInstance
    include ActiveDynamoDB::AttributeInstance
    include ActiveDynamoDB::Validators
    class << self
      include ActiveDynamoDB::Connection
      include ActiveDynamoDB::TableConfig
      include ActiveDynamoDB::Table
      include ActiveDynamoDB::Persistence
      include ActiveDynamoDB::Query
      include ActiveDynamoDB::Association
      include ActiveDynamoDB::Attribute
      include ActiveDynamoDB::RelationSupport
    end
  end
end
