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

require 'overrides/ansible/property_override'

module Provider
  module Azure
    module Ansible

      class PropertyOverride < Overrides::Ansible::PropertyOverride
        # Collection of fields allowed in the PropertyOverride section for
        # Ansible. All fields should be `attr_reader :<property>`
        def self.attributes
          super.concat(%i[
            resource_type_name
            document_sample_value
            custom_normalize
            inline_custom_response_format
          ])
        end

        attr_reader(*attributes)

        def validate
          super
          check :resource_type_name, type: ::String
          check :document_sample_value, type: ::String
          check :custom_normalize, type: ::String
          check :inline_custom_response_format, type: ::String
        end
      end

    end
  end
end
