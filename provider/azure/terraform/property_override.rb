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

require 'overrides/terraform/property_override'

module Provider
  module Azure
    module Terraform

      class PropertyOverride < Overrides::Terraform::PropertyOverride
        def self.attributes
          super.concat(%i[
            name_in_logs
            hide_from_schema
            true_value
            false_value
            custom_schema_definition
            custom_schema_get
            custom_schema_set
            custom_sdkfield_assign
            custom_ef_func_name
          ])
        end

        attr_reader(*attributes)

        def validate
          super
          check :name_in_logs, type: ::String
          check :hide_from_schema, type: :boolean, default: false
          check :true_value, type: [Symbol]
          check :false_value, type: [Symbol]
          check :custom_schema_definition, type: ::String
          check :custom_schema_get, type: ::String
          check :custom_schema_set, type: ::String
          check :custom_sdkfield_assign, type: ::String
          check :custom_ef_func_name, type: ::String
        end
      end

    end
  end
end
