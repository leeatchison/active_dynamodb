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

    define_model_callbacks :create, :update, :save, :destroy

  end
end
