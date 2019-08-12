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
require 'api/azure/sdk_operation_definition_override'

module Api
  module Azure
    class SDKDefinitionOverride < Api::Object
      attr_reader :create
      attr_reader :read
      attr_reader :update
      attr_reader :delete

      def validate
        super
        check :create, type: SDKOperationDefinitionOverride
        check :read, type: SDKOperationDefinitionOverride
        check :update, type: SDKOperationDefinitionOverride
        check :delete, type: SDKOperationDefinitionOverride
      end
    end
  end
end
