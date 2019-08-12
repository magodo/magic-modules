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

require 'overrides/terraform/resource_override'
require 'api/azure/sdk_definition_override'

module Provider
  module Azure
    module Terraform

      class DocumentExampleReference < Api::Object
        attr_reader :title
        attr_reader :example_name
        attr_reader :resource_name_hints

        def validate
          super
          check :title, type: ::String, required: true
          check :example_name, type: ::String, required: true
          check_ext :resource_name_hints, type: ::Hash, key_type: ::String, item_type: ::String
        end
      end

      class DataSourceExampleReference < Api::Object
        attr_reader :title
        attr_reader :example_name

        def validate
          super
          check :title, type: ::String, required: true
          check :example_name, type: ::String, required: true
        end
      end

      class AccTestDefinition < Api::Object
        attr_reader :name
        attr_reader :steps

        def validate
          super
          @initialized = false

          check :name, type: ::String, required: true
          check :steps, type: ::Array, item_type: ::String, required: true
        end
      end

      class ResourceOverride < Overrides::Terraform::ResourceOverride
        def self.attributes
          super.concat(%i[
            azure_sdk_definition
            name_in_logs
            document_examples
            acctests
            datasource_example_outputs
          ])
        end

        attr_reader(*attributes)

        def validate
          super
          check :azure_sdk_definition, type: Api::Azure::SDKDefinitionOverride
          check :name_in_logs, type: ::String
          check :document_examples, type: ::Array, item_type: DocumentExampleReference
          check :acctests, type: ::Array, item_type: AccTestDefinition
          check :datasource_example_outputs, type: ::Hash
        end

        def apply(_resource)
          filter_azure_sdk_language _resource, "go"
          merge_azure_sdk_definition _resource, @azure_sdk_definition
          @azure_sdk_definition = nil
          super
        end
      end

    end
  end
end
