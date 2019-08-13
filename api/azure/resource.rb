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

require 'google/yaml_validator'
require 'api/azure/sdk_definition'

module Api
  module Azure
    # The Azure-extended module which will be injected to Api::Resource
    module Resource
      # The Azure-extended properties which supplement Api::Resource::Properties
      module Properties
        attr_reader :azure_sdk_definition
      end

      # Azure-extended validate function of Api::Resource::validate
      def azure_validate
        check :azure_sdk_definition, type: Api::Azure::SDKDefinition, required: true
      end
    end
  end
end
