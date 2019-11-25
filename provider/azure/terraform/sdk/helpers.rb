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

require 'provider/azure/terraform/sdk/expand_flatten_descriptor'

module Provider
  module Azure
    module Terraform
      module SDK
        module Helpers
          def get_properties_matching_sdk_reference(properties, sdk_reference)
            properties.select{|p| p.azure_sdk_references.include?(sdk_reference)}.sort_by{|p| [p.order, p.name]}
          end

          def get_applicable_reference(references, typedefs)
            references.each do |ref|
              return ref if typedefs.has_key?(ref)
            end
            nil
          end

          def get_sdk_typedef_by_references(references, typedefs)
            ref = get_applicable_reference(references, typedefs)
            return nil if ref.nil?
            typedefs[ref]
          end

          def get_corresponding_schema_marshal(sdk_marshal, property, req_resp_body)
            this_api_path = get_applicable_reference(property.azure_sdk_references, req_resp_body)
            sdk_marshal.clone(this_api_path)
          end

          def property_to_schema_assignment_template(property, sdk_operation, api_path)
            return 'templates/azure/terraform/sdktypes/primitive_schema_assign.erb' if property.is_a?(Api::Azure::Type::BooleanEnum)
            sdk_type = sdk_operation.response[api_path] || sdk_operation.request[api_path]
            case sdk_type
            when Api::Azure::SDKTypeDefinition::BooleanObject, Api::Azure::SDKTypeDefinition::StringObject,
                 Api::Azure::SDKTypeDefinition::IntegerObject, Api::Azure::SDKTypeDefinition::Integer32Object,
                 Api::Azure::SDKTypeDefinition::Integer64Object, Api::Azure::SDKTypeDefinition::FloatObject,
                 Api::Azure::SDKTypeDefinition::StringArrayObject, Api::Azure::SDKTypeDefinition::StringMapObject,
                 Api::Azure::SDKTypeDefinition::ISO8601DateTimeObject, Api::Azure::SDKTypeDefinition::ISO8601DurationObject,
                 Api::Azure::SDKTypeDefinition::Integer32ArrayObject, Api::Azure::SDKTypeDefinition::Integer64ArrayObject,
                 Api::Azure::SDKTypeDefinition::FloatArrayObject
              'templates/azure/terraform/sdktypes/primitive_schema_assign.erb'
            when Api::Azure::SDKTypeDefinition::EnumObject
              'templates/azure/terraform/sdktypes/enum_schema_assign.erb'
            when Api::Azure::SDKTypeDefinition::ComplexObject
              return 'templates/azure/terraform/sdktypes/nested_object_schema_assign.erb' if property.nil?
              'templates/azure/terraform/sdktypes/primitive_schema_assign.erb'
            else
              'templates/azure/terraform/sdktypes/unsupport.erb'
            end
          end
        end
      end
    end
  end
end