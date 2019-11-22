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

require 'provider/azure/terraform/helpers'
require 'provider/terraform/sub_template'
require 'provider/azure/terraform/sub_template'
require 'api/object'

module Api
  module Azure

    # forward declaration
    class SDKTypeDefinition < Api::Object
    end

    class << SDKTypeDefinition

      # Generate instance method that render property to sdk field.
      # `build_expr` is a proc which will resolve expand field expression.
      def render_property_to_sdk_field(&build_expr)

        define_method 'render_property_to_sdk_field' do |property, sdk_marshal, in_structure: true|
          if get_property_value(property, "hide_from_schema", false)
            return compile_template('templates/azure/terraform/schemas/hide_from_schema.erb')
          end

          unless get_property_value(property, "custom_sdkfield_assign", nil).nil?
            return compile_template property.custom_sdkfield_assign,
                                    sdk_marshal: sdk_marshal,
                                    property: property,
                                    in_structure: in_structure
          end

          compile_template 'templates/azure/terraform/sdktypes/property_to_sdk_field_assign.erb',
                           sdk_marshal: sdk_marshal,
                           property: property,
                           field_expression: build_expr.call(sdk_marshal, property),
                           in_structure: in_structure
        end
      end

      def build_var_name(sdk_marshal, property)
        sdk_marshal.sdktype.type_definition.go_variable_name || property.name.camelcase(:lower)
      end

    end

    class SDKTypeDefinition

      include Provider::Azure::Terraform::Helpers
      include Provider::Azure::Terraform::SubTemplate
      include Provider::Terraform::SubTemplate
      include Compile::Core

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
        check_ext :applicable_to, type: ::Array, item_type: ::String, item_allowed: %w[go python], default: %w[go python]
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
        @id_portion = overrides.id_portion unless overrides.id_portion.nil?
        @empty_value_sensitive = overrides.empty_value_sensitive unless overrides.empty_value_sensitive.nil?
        @go_variable_name = overrides.go_variable_name unless overrides.go_variable_name.nil?
        @go_field_name = overrides.go_field_name unless overrides.go_field_name.nil?
        @go_type_name = overrides.go_type_name unless overrides.go_type_name.nil?
        @is_pointer_type = overrides.is_pointer_type unless overrides.is_pointer_type.nil?
        @python_parameter_name = overrides.python_parameter_name unless overrides.python_parameter_name.nil?
        @python_variable_name = overrides.python_variable_name unless overrides.python_variable_name.nil?
        @python_field_name = overrides.python_field_name unless overrides.python_field_name.nil?
      end

      def render_property_to_sdk_field(_sdk_marshal, _property, _in_structure: false)
        raise NotImplementedError
      end

      class BooleanObject < SDKTypeDefinition
        render_property_to_sdk_field do |sdk_marshal, property|
          "utils.Bool(#{build_var_name(sdk_marshal, property)})"
        end
      end

      class IntegerObject < SDKTypeDefinition
        render_property_to_sdk_field do |sdk_marshal, property|
          "utils.Int(#{build_var_name(sdk_marshal, property)})"
        end
      end

      class Integer32Object < SDKTypeDefinition
        render_property_to_sdk_field do |sdk_marshal, property|
          "utils.Int32(int32(#{build_var_name(sdk_marshal, property)}))"
        end
      end

      class Integer64Object < SDKTypeDefinition
        render_property_to_sdk_field do |sdk_marshal, property|
          "utils.Int64(int64(#{build_var_name(sdk_marshal, property)}))"
        end
      end

      class Integer32ArrayObject < SDKTypeDefinition
        render_property_to_sdk_field do |sdk_marshal, property|
          "utils.ExpandInt32Slice(#{build_var_name(sdk_marshal, property)})"
        end
      end

      class Integer64ArrayObject < SDKTypeDefinition
        render_property_to_sdk_field do |sdk_marshal, property|
          "utils.ExpandInt64Slice(#{build_var_name(sdk_marshal, property)})"
        end
      end

      class FloatObject < SDKTypeDefinition
        render_property_to_sdk_field do |sdk_marshal, property|
          "utils.Float(float32(#{build_var_name(sdk_marshal, property)}))"
        end
      end

      class FloatArrayObject < SDKTypeDefinition
        render_property_to_sdk_field do |sdk_marshal, property|
          "utils.ExpandStringFloat32(#{build_var_name(sdk_marshal, property)})"
        end
      end

      class StringObject < SDKTypeDefinition
        render_property_to_sdk_field do |sdk_marshal, property|
          "utils.String(#{build_var_name(sdk_marshal, property)})"
        end
      end

      class EnumObject < SDKTypeDefinition
        render_property_to_sdk_field do |sdk_marshal, property|
          var_name = build_var_name(sdk_marshal, property)
          case property
          when Api::Azure::Type::BooleanEnum
            var_name
          else
            "utils.String(#{var_name})"
          end
        end

        attr_reader :go_enum_type_name
        attr_reader :go_enum_const_prefix

        def validate
          super
          check :go_enum_type_name, type: ::String
          check :go_enum_const_prefix, type: ::String, default: ''
        end

        def merge_overrides!(overrides)
          super
          # `overrides` is instance of either SDKTypeDefinitionOverride or
          # SDKTypeDefinitionOverride::EnumObjectOverride. We only merge type specific
          # attribute for the latter case.
          return unless overrides.instance_of? Api::Azure::SDKTypeDefinitionOverride::EnumObjectOverride

          @go_enum_type_name = overrides.go_enum_type_name unless overrides.go_enum_type_name.nil?
          @go_enum_const_prefix = overrides.go_enum_const_prefix unless overrides.go_enum_const_prefix.nil?
        end
      end

      class EnumArrayObject < SDKTypeDefinition
        render_property_to_sdk_field do |sdk_marshal, property|
          "expand#{sdk_marshal.enqueue(property, $global_expand_queue)}(#{build_var_name(sdk_marshal, property)})"
        end
      end

      class ISO8601DurationObject < SDKTypeDefinition
        render_property_to_sdk_field do |sdk_marshal, property|
          "utils.String(#{build_var_name(sdk_marshal, property)})"
        end
      end

      class ISO8601DateTimeObject < SDKTypeDefinition
        # TODO: side effect and error-prone (see enqueue implementation)
        render_property_to_sdk_field do |sdk_marshal, property|
          "expand#{sdk_marshal.enqueue(property, $global_expand_queue)}(#{build_var_name(sdk_marshal, property)})"
        end
      end

      class ComplexObject < SDKTypeDefinition
        render_property_to_sdk_field do |sdk_marshal, property|
          # TODO: side effect
          next "expand#{sdk_marshal.enqueue(property, $global_expand_queue)}(#{build_var_name(sdk_marshal, property)})" unless property.nil?

          <<~EOF
            &#{sdk_marshal.package}.#{sdk_marshal.sdktype.go_type_name}{
            #{build_property_to_sdk_object(sdk_marshal)}
            }
          EOF
        end
      end

      class StringArrayObject < SDKTypeDefinition
        render_property_to_sdk_field do |sdk_marshal, property|
          "utils.ExpandStringSlice(#{build_var_name(sdk_marshal, property)})"
        end
      end

      class ComplexArrayObject < SDKTypeDefinition
        render_property_to_sdk_field do |sdk_marshal, property|
          "expand#{sdk_marshal.enqueue(property, $global_expand_queue)}(#{build_var_name(sdk_marshal, property)})"
        end
      end

      class StringMapObject < SDKTypeDefinition
        # TODO: add render property method
        render_property_to_sdk_field do |sdk_marshal, property|
          next 'tags.Expand(t)' if property.instance_of? Api::Azure::Type::Tags
          # TODO
          #"#{expand_func}(#{build_var_name(sdk_marshal, property)})"
        end
      end
    end
  end
end
