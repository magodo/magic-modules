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

require 'api/type'

module Api
  module Azure
    module Type
      # Represents an Azure resource group name type used in properties of api.yaml
      class ResourceGroupName < Api::Type::String
        def validate
          @order ||= 3
          super
        end
      end

      # Represents an Azure location type used in properties of api.yaml
      class Location < Api::Type::String
        def validate
          @order ||= 5
          super
        end
      end

      # Represents an Azure tags type used in properties of api.yaml
      class Tags < Api::Type::KeyValuePairs
        def validate
          @order ||= 20
          super
        end
      end

      # Represents an Azure resource ID type used in properties of api.yaml
      class ResourceReference < Api::Type::String
        attr_reader :resource_type_name

        def validate
          super
          check :resource_type_name, type: ::String, required: true
        end
      end

      # Represents an Azure ISO8601 duration string type used in properties of api.yaml
      class ISO8601Duration < Api::Type::String
      end

      # Represents an Azure ISO8601 date time string type used in properties of api.yaml
      class ISO8601DateTime < Api::Type::String
      end
    end
  end
end
