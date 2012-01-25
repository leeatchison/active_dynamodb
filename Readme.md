# Active DynamoDB
This gem is a Rails ActiveModel implementation of an ORB for
Amazon AWS's DynamoDB service.

# THIS IS A WORK IN PROGRESS
It is not yet ready to be used by others. However, suggestions for
improvements, pulls, and bug reports are all appreciated.

Thanks!

# Tests
I am still trying to figure out the best way to test with DynamoDB. While
I could stub or mock, I want to look into ways to QA with the live DynamoDB
service, but test-mode tables... This is still a work in progress...



# Documentation In Progress...

# Install/Setup

# Basic Model Configuration

An ActiveDynamicDB model must be setup as follows:

class MyModel << ActiveDynamoDB::Base
  field :myfield, type: :integer
  ...
end


## Table Naming

# Creating Table and Managing Tables
