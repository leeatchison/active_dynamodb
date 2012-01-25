module ActiveDynamoDB
  module Validators
    #
    # Validators
    #
    class UniquenessValidator < ActiveModel::EachValidator
      def initialize(options)
        super(options.reverse_merge(:case_sensitive => true))
      end
      def setup(klass)
        @klass = klass
      end
      def validate_each(record, attribute, value)
        matcher=@klass.where(attribute=>value)
        match=matcher.where(options[:scope]=>record.send(options[:scope])) if options[:scope]
        any_match=matcher.first
        if any_match
          if any_match.id!=record.id
            record.errors.add(attribute, :taken, options.except(:case_sensitive, :scope).merge(:value => value))
          end
        end
      end
    end
  end
end
