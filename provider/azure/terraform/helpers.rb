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

module Provider
  module Azure
    module Terraform
      module Helpers
        def get_property_value(obj, prop_name, default_value)
          return default_value unless obj.instance_variable_defined?("@#{prop_name}")
          obj.instance_variable_get("@#{prop_name}")
        end

        def order_azure_properties(properties, data_source_input = [])
          special_props = properties.select{|p| p.name == 'name' || p.name == 'location' || p.name == 'resourceGroupName' || p.name == 'resourceGroup' || data_source_input.include?(p)}
          other_props = properties.reject{|p| p.name == 'name' || p.name == 'location' || p.name == 'resourceGroupName' || p.name == 'resourceGroup' || p.name == 'tags' || data_source_input.include?(p)}
          sorted_special = special_props.sort_by{|p| p.name == 'location' ? 2 : p.order }
          sorted_other = data_source_input.empty? ? order_properties(other_props) : other_props.sort_by(&:name)
          sorted_special + sorted_other + properties.select{|p| p.name == 'tags'}
        end

        def is_tags_defined?(sdk_operation)
          sdk_operation.response.has_key?('/tags')
        end

        def go_field_name_of_tags(sdk_operation)
          sdk_operation.response['/tags'].go_field_name
        end

        def go_temp_var_name(sdk_type_def, reserved: nil)
          name = sdk_type_def.go_variable_name || sdk_type_def.go_field_name.underscore.camelcase(:lower) || reserved
          raise 'No temp var name specified' if name.nil?
          name
        end
      end
    end
  end
end
