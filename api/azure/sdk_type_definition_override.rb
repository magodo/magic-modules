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

module Api
  module Azure
    # CRUDL operation request/response values in terraform.yaml or ansible.yaml
    class SDKTypeDefinitionOverride < SDKTypeDefinition
      attr_reader :remove

      def validate
        super
        check :remove, type: :boolean, default: false
      end
    end
  end
end
