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
    # Base type which will be used as CRUDL operation request/response values in api.yaml
    class SDKTypeDefinition < Api::Object
      attr_reader :id_portion
      attr_reader :applicable_to
      attr_reader :empty_value_sensitive
      attr_reader :go_variable_name
      attr_reader :go_field_name
      attr_reader :go_type_name
      attr_reader :is_pointer_type
      attr_reader :python_parameter_name
      attr_reader :python_variable_name
      attr_reader :python_field_name

      def validate
        super
        check :id_portion, type: ::String
        check_ext :applicable_to,
                  type: ::Array,
                  item_type: ::String,
                  item_allowed: %w[go python],
                  default: %w[go python]
        check :empty_value_sensitive, type: :boolean, default: false
        check :go_variable_name, type: ::String
        check :go_field_name, type: ::String
        check :go_type_name, type: ::String
        check :is_pointer_type, type: :boolean, default: false
        check :python_parameter_name, type: ::String
        check :python_variable_name, type: ::String
        check :python_field_name, type: ::String
      end

      def merge_overrides!(overrides)
        merge_attr! :@id_portion, overrides.id_portion
        merge_attr! :@empty_value_sensitive, overrides.empty_value_sensitive
        merge_attr! :@go_variable_name, overrides.go_variable_name
        merge_attr! :@go_field_name, overrides.go_field_name
        merge_attr! :@is_pointer_type, overrides.is_pointer_type
        merge_attr! :@python_parameter_name, overrides.python_parameter_name
        merge_attr! :@python_variable_name, overrides.python_variable_name
        merge_attr! :@python_field_name, overrides.python_field_name
      end

      # Represents a boolean type (e.g. bool) in SDK
      class BooleanObject < SDKTypeDefinition
      end

      # Represents a platform-specific integer (e.g. int) type in SDK
      class IntegerObject < SDKTypeDefinition
      end

      # Represents a 32-bit integer type (e.g. int32_t) in SDK
      class Integer32Object < SDKTypeDefinition
      end

      # Represents a 64-bit integer type (e.g. int64_t) in SDK
      class Integer64Object < SDKTypeDefinition
      end

      # Represents a 64-bit float point type (e.g. double) in SDK
      class FloatObject < SDKTypeDefinition
      end

      # Represents a string type (e.g. string) in SDK
      class StringObject < SDKTypeDefinition
      end

      # Represents a enumeration type (e.g. enum) in SDK
      class EnumObject < SDKTypeDefinition
        attr_reader :go_enum_type_name
        attr_reader :go_enum_const_prefix

        def validate
          super
          check :go_enum_type_name, type: ::String
          check :go_enum_const_prefix, type: ::String, default: ''
        end
      end

      # Represents a specifically ISO8601 duration type (e.g. chrono::duration) in SDK
      class ISO8601DurationObject < StringObject
      end

      # Represents a specifically ISO8601 date time type (e.g. chrono::time_point) in SDK
      class ISO8601DateTimeObject < SDKTypeDefinition
      end

      # Represents a nested object type (e.g. struct/class) in SDK
      class ComplexObject < SDKTypeDefinition
      end

      # Represents an array of strings type (e.g. string[]) in SDK
      class StringArrayObject < SDKTypeDefinition
      end

      # Represents an array of nested objects type (e.g. struct/class[]) in SDK
      class ComplexArrayObject < ComplexObject
      end

      # Represents a string-to-string hash table type (e.g. map<string, string>) in SDK
      class StringMapObject < SDKTypeDefinition
      end

      private

      def merge_attr!(sym, val)
        instance_variable_set(sym, val) unless val.nil?
      end
    end
  end
end
