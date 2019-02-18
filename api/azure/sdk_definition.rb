require 'api/object'
require 'api/azure/sdk_operation_definition'

module Api
  module Azure
    class SDKDefinition < Api::Object
      attr_reader :provider_name
      attr_reader :create
      attr_reader :read
      attr_reader :update
      attr_reader :delete

      def validate
        super
        check_optional_property :provider_name, String
        check_property :create, Api::Azure::SDKOperationDefinition
        check_property :read, Api::Azure::SDKOperationDefinition
        check_property :update, Api::Azure::SDKOperationDefinition
        check_property :delete, Api::Azure::SDKOperationDefinition
      end
    end
  end
end
