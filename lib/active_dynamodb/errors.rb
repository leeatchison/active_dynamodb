module ActiveDynamoDB
  #
  #
  # Errors
  #
  #
  class ConnectionNotDefined<Exception;end
  class CantFindTable<Exception;end
  class InvalidAttributeType<Exception;end
  class InvalidField<Exception;end
  class UnknownAttributeError<Exception;end
  class InvalidCounterTable<Exception;end
  class InvalidCounterKey<Exception;end
  class InvalidAttribute<Exception;end
  class CouldNotFindItemInDatabase<Exception;end
  class InvalidRelationshipType<Exception;end
  class InvalidAssociation<Exception;end
  class ObjectIsNotPeristed<Exception;end
  class TableNotBeingCreated<Exception;end
  class TableNotBeingDeleted<Exception;end
end
