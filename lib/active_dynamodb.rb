require "active_dynamodb/version"
require "active_dynamodb/errors"
require "active_dynamodb/logger"
require "active_dynamodb/dynamodb_connection"
require "active_dynamodb/table_config"
require "active_dynamodb/table"
require "active_dynamodb/associations"
require "active_dynamodb/attributes"
require "active_dynamodb/query"
require "active_dynamodb/relation"
require "active_dynamodb/validators"
require "active_dynamodb/persistence"
require "active_dynamodb/base"

#
# TODOs:
#   ***- Implement dependent: :destroy and :delete
#   ***- Methods defined on the base class should be available from within a Relation scope (http://guides.rubyonrails.org/active_record_querying.html#scopes, Section 13.2)
#   - Scopes
#   - related relations
#   - unsaved objects...
#   - has_many, :through=>
#   - caching
#   - has_many callbacks: before_add, after_add, before_remove, after_remove
#
