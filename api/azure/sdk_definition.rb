# Copyright 2019 Microsoft Corp.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'api/object'
require 'api/azure/sdk_operation_definition'

module Api
  module Azure
    # The azure_sdk_definition section used in api.yaml
    class SDKDefinition < Api::Object
      attr_reader :provider_name
      attr_reader :go_client_namespace
      attr_reader :go_client
      attr_reader :python_client_namespace
      attr_reader :python_client
      attr_reader :create
      attr_reader :read
      attr_reader :update
      attr_reader :delete
      attr_reader :list_by_parent
      attr_reader :list_by_resource_group
      attr_reader :list_by_subscription

      def validate
        super
        check :provider_name, type: ::String, required: true
        check :go_client_namespace, type: ::String, required: true
        check :go_client, type: ::String, required: true
        check :python_client_namespace, type: ::String, required: true
        check :python_client, type: ::String, required: true
        check :create, type: Api::Azure::SDKOperationDefinition, required: true
        check :read, type: Api::Azure::SDKOperationDefinition, required: true
        check :update, type: Api::Azure::SDKOperationDefinition
        check :delete, type: Api::Azure::SDKOperationDefinition, required: true
        check :list_by_parent, type: Api::Azure::SDKOperationDefinition
        check :list_by_resource_group, type: Api::Azure::SDKOperationDefinition
        check :list_by_subscription, type: Api::Azure::SDKOperationDefinition
      end

      def filter_language!(language)
        @create&.filter_language!(language)
        @read&.filter_language!(language)
        @update&.filter_language!(language)
        @delete&.filter_language!(language)
      end

      def merge_overrides!(overrides)
        @create&.merge_overrides!(overrides.create) unless overrides.create.nil?
        @read&.merge_overrides!(overrides.read) unless overrides.read.nil?
        @update&.merge_overrides!(overrides.update) unless overrides.update.nil?
        @delete&.merge_overrides!(overrides.delete) unless overrides.delete.nil?
      end
    end
  end
end
