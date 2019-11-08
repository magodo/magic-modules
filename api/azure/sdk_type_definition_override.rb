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
    class SDKTypeDefinitionOverride < SDKTypeDefinition
      attr_reader :remove

      def validate
        super
        check :remove, type: :boolean, default: false
      end

      class BooleanObjectOverride < SDKTypeDefinitionOverride
      end

      class IntegerObjectOverride < SDKTypeDefinitionOverride
      end

      class Integer32ObjectOverride < SDKTypeDefinitionOverride
      end

      class Integer64ObjectOverride < SDKTypeDefinitionOverride
      end

      class Integer32ArrayObjectOverride < SDKTypeDefinitionOverride
      end

      class Integer64ArrayObjectOverride < SDKTypeDefinitionOverride
      end

      class FloatObjectOverride < SDKTypeDefinitionOverride
      end

      class StringObjectOverride < SDKTypeDefinitionOverride
      end

      class EnumObjectOverride < SDKTypeDefinitionOverride
        attr_reader :go_enum_type_name
        attr_reader :go_enum_const_prefix

        def validate
          super
          check :go_enum_type_name, type: ::String
          check :go_enum_const_prefix, type: ::String, default: ''
        end
      end

      class EnumArrayObjectOverride < EnumObjectOverride
      end

      class ISO8601DurationObjectOverride < StringObjectOverride
      end

      class ISO8601DateTimeObjectOverride < SDKTypeDefinitionOverride
      end

      class ComplexObjectOverride < SDKTypeDefinitionOverride
      end

      class StringArrayObjectOverride < SDKTypeDefinitionOverride
      end

      class ComplexArrayObjectOverride < ComplexObjectOverride
      end

      class StringMapObjectOverride < SDKTypeDefinitionOverride
      end
    end
  end
end
