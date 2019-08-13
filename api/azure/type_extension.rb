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

module Api
  module Azure
    module Type
      # The Azure-extended module which will be injected to Api::Type::Fields
      module Fields
        attr_reader :order
        attr_reader :sample_value
        attr_reader :azure_sdk_references
      end

      # The Azure-extended module which will be injected to Api::Type
      module TypeExtension
        def azure_validate
          default_order = 10
          default_order = 1 if @name == 'name'
          default_order = -1 if @name == 'id'
          check :order, type: ::Integer, default: default_order
          check :azure_sdk_references, type: ::Array, item_type: ::String
        end
      end
    end
  end
end
