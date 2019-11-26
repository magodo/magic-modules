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

      def build_ef_func_name(&build_default_name)
        define_method 'build_ef_func_name' do |property|
          return property.custom_ef_func_name unless property.custom_ef_func_name.nil?

          build_default_name.call(sdk_marshal, property)
        end
      end

      def render_property_get(&build_func_name)
        define_method 'render_property_get' do |sdk_marshal, property, schema_var_name, indentation: 4|
          if build_func_name&.call(sdk_marshal, property).nil? # either build_func_name not given or it returns nil
            compile_template 'templates/azure/terraform/schemas/property_get.erb',
                             indentation: indentation,
                             var_name: build_var_name(property),
                             schema_var_name: schema_var_name,
                             prop_name: property.name.camelcase(:lower),
                             go_type: property.go_type
          else
            compile_template 'templates/azure/terraform/schemas/property_get_with_error.erb',
                             indentation: indentation,
                             var_name: build_var_name(property),
                             schema_var_name: schema_var_name,
                             prop_name: property.name.camelcase(:lower),
                             go_type: property.go_type,
                             func_name: build_func_name.call(sdk_marshal, property)
          end
        end
      end

      # Generate instance method that render property to sdk field.
      # `build_expr` is a proc which will resolve expand field expression.
      def render_property_to_sdk_field(&build_func_name)
        define_method 'render_property_to_sdk_field' do |sdk_marshal, property, in_structure: true, indentation: 4|
          unless get_property_value(property, "custom_sdkfield_assign", nil).nil?
            return compile_template property.custom_sdkfield_assign,
                                    indentation: indentation,
                                    sdk_marshal: sdk_marshal,
                                    property: property,
                                    in_structure: in_structure
          end

          var_name = build_var_name property
          expression = build_func_name.call sdk_marshal, property, var_name
          compile_template 'templates/azure/terraform/sdktypes/property_to_sdk_field_assign.erb',
                           indentation: indentation,
                           field_name: go_field_name,
                           field_expression: expression,
                           in_structure: in_structure
        end
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

      def build_var_name(property)
        go_variable_name || property.name.camelcase(:lower)
      end

      def build_ef_func_name(sdk_marshal, property)
        raise NotImplementedError
      end

      def render_property_to_sdk_field(_sdk_marshal, _property, _in_structure: false)
        raise NotImplementedError
      end

      def render_property_get(sdk_marshal, property, schema_var_name)
        raise NotImplementedError
      end

      def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var)
        raise NotImplementedError
      end

      class BooleanObject < SDKTypeDefinition
        render_property_get

        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          "utils.Bool(#{var_name})"
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          value = "#{resp_var}.#{sdk_marshal.sdktype.type_definition.go_field_name}"
          compile_template 'templates/azure/terraform/schemas/property_set.erb',
                           indentation: indentation,
                           value: value,
                           schema_var_name: schema_var_name,
                           prop_name: property.name.camelcase(:lower)
        end
      end

      class IntegerObject < SDKTypeDefinition
        render_property_get

        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          "utils.Int(#{var_name})"
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          value = "#{resp_var}.#{sdk_marshal.sdktype.type_definition.go_field_name}"
          compile_template 'templates/azure/terraform/schemas/property_set.erb',
                           indentation: indentation,
                           value: value,
                           schema_var_name: schema_var_name,
                           prop_name: property.name.camelcase(:lower)
        end
      end

      class Integer32Object < SDKTypeDefinition
        render_property_get

        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          "utils.Int32(int32(#{var_name}))"
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          value = "int(*#{resp_var}.#{sdk_marshal.sdktype.type_definition.go_field_name})"
          compile_template 'templates/azure/terraform/schemas/property_set.erb',
                           indentation: indentation,
                           value: value,
                           schema_var_name: schema_var_name,
                           prop_name: property.name.camelcase(:lower)
        end
      end

      class Integer64Object < SDKTypeDefinition
        render_property_get

        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          "utils.Int64(int64(#{var_name}))"
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          value = "int(*#{resp_var}.#{go_field_name})"
          compile_template 'templates/azure/terraform/schemas/property_set.erb',
                           indentation: indentation,
                           value: value,
                           schema_var_name: schema_var_name,
                           prop_name: property.name.camelcase(:lower)
        end
      end

      class Integer32ArrayObject < SDKTypeDefinition
        render_property_get

        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          "utils.ExpandInt32Slice(#{var_name})"
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          value = "utils.FlattenInt32Slice(#{resp_var}.#{go_field_name})"
          compile_template 'templates/azure/terraform/schemas/property_set_with_error.erb',
                           indentation: indentation,
                           value: value,
                           schema_var_name: schema_var_name,
                           prop_name: property.name.camelcase(:lower)
        end
      end

      class Integer64ArrayObject < SDKTypeDefinition
        render_property_get

        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          "utils.ExpandInt64Slice(#{var_name})"
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          value = "utils.FlattenInt64Slice(#{resp_var}.#{go_field_name})"
          compile_template 'templates/azure/terraform/schemas/property_set_with_error.erb',
                           indentation: indentation,
                           value: value,
                           schema_var_name: schema_var_name,
                           prop_name: property.name.camelcase(:lower)
        end
      end

      class FloatObject < SDKTypeDefinition
        render_property_get

        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          "utils.Float(float64(#{var_name}))"
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          value = "#{resp_var}.#{go_field_name}"
          compile_template 'templates/azure/terraform/schemas/property_set.erb',
                           indentation: indentation,
                           value: value,
                           schema_var_name: schema_var_name,
                           prop_name: property.name.camelcase(:lower)
        end
      end

      class FloatArrayObject < SDKTypeDefinition
        render_property_get

        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          "utils.ExpandFloat64Slice(#{var_name})"
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          value = "utils.FlattenFloat64Slice(#{resp_var}.#{go_field_name})"
          compile_template 'templates/azure/terraform/schemas/property_set_with_error.erb',
                           indentation: indentation,
                           value: value,
                           schema_var_name: schema_var_name,
                           prop_name: property.name.camelcase(:lower)
        end
      end

      class StringObject < SDKTypeDefinition

        render_property_get

        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          "utils.String(#{var_name})"
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          return render_sdk_field_to_property_for_location(sdk_marshal, property, schema_var_name, resp_var, indentation: indentation) if property.instance_of? Api::Azure::Type::Location

          # Special handling for id property corresponding to url parameters
          value = if id_portion.nil?
                    "#{resp_var}.#{go_field_name}"
                  else
                    go_variable_name
                  end
          compile_template 'templates/azure/terraform/schemas/property_set.erb',
                           indentation: indentation,
                           value: value,
                           schema_var_name: schema_var_name,
                           prop_name: property.name.camelcase(:lower)
        end

        private

        def render_sdk_field_to_property_for_location(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          compile_template 'templates/azure/terraform/schemas/location_set.erb',
                           indentation: indentation,
                           input_var: "#{resp_var}.Location",
                           output_var: schema_var_name,
                           prop_name: property.name.camelcase(:lower)
        end

      end

      class EnumObject < SDKTypeDefinition
        render_property_get

        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          case property
          when Api::Azure::Type::BooleanEnum
            var_name
          else
            "#{sdk_marshal.package}.#{sdk_marshal.sdktype.type_definition.go_enum_type_name}(#{var_name})"
          end
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          value = "string(#{resp_var}.#{go_field_name})"
          compile_template 'templates/azure/terraform/schemas/property_set.erb',
                           indentation: indentation,
                           value: value,
                           schema_var_name: schema_var_name,
                           prop_name: property.name.camelcase(:lower)
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
        build_ef_func_name do |sdk_marshal, property|
          "#{sdk_marshal.resource}#{go_type_name}Array"
        end

        render_property_get

        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          # TODO: side effect and error-prone (see enqueue implementation)
          "expand#{sdk_marshal.enqueue(property, $global_expand_queue)}(#{var_name})"
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          # TODO
          raise NotImplementedError
        end
      end

      class ISO8601DurationObject < SDKTypeDefinition
        render_property_get

        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          "utils.String(#{var_name})"
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          value = "#{resp_var}.#{go_field_name}"
          compile_template 'templates/azure/terraform/schemas/property_set.erb',
                           indentation: indentation,
                           value: value,
                           schema_var_name: schema_var_name,
                           prop_name: property.name.camelcase(:lower)
        end
      end

      class ISO8601DateTimeObject < SDKTypeDefinition
        render_property_get do |sdk_marshal, property|
          # TODO: maybe here need some indication to tell whether treat timestamp as UTC or local
          "datetime.ParseUTC"
        end

        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          "&date.Time{#{var_name}}"
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          value = "(#{resp_var}.#{go_field_name}).String()"
          compile_template 'templates/azure/terraform/schemas/property_set.erb',
                           indentation: indentation,
                           value: value,
                           schema_var_name: schema_var_name,
                           prop_name: property.name.camelcase(:lower)
        end
      end

      class ComplexObject < SDKTypeDefinition
        build_ef_func_name do |sdk_marshal, property|
          "#{sdk_marshal.resource}#{go_type_name}"
        end

        render_property_get do |sdk_marshal, property|
          # TODO: side effect
          next "expand#{sdk_marshal.enqueue(property, $global_expand_queue)}" unless property.nil?
        end

        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          next var_name unless property.nil?

          # For top level complex object (a.k.a. '/parameters')
          <<~EOF
            &#{sdk_marshal.package}.#{sdk_marshal.sdktype.go_type_name}{
            #{build_property_to_sdk_object(sdk_marshal)}
            }
          EOF
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          # TODO: side effect
          flatten_func_name = "flatten#{sdk_marshal.enqueue(property, $global_flatten_queue)}"
          value = "#{flatten_func_name}(#{resp_var}.#{go_field_name})"
          compile_template 'templates/azure/terraform/schemas/property_set_with_flatten.erb',
                           indentation: indentation,
                           var_name: build_var_name(property),
                           value: value,
                           schema_var_name: schema_var_name,
                           prop_name: property.name.camelcase(:lower)
        end
      end

      class StringArrayObject < SDKTypeDefinition
        render_property_get

        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          "utils.ExpandStringSlice(#{var_name})"
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          value = "utils.FlattenStringSlice(#{resp_var}.#{go_field_name})"
          compile_template 'templates/azure/terraform/schemas/property_set.erb',
                           indentation: indentation,
                           value: value,
                           schema_var_name: schema_var_name,
                           prop_name: property.name.camelcase(:lower)
        end
      end

      class ComplexArrayObject < SDKTypeDefinition
        build_ef_func_name do |sdk_marshal, property|
          "#{sdk_marshal.resource}#{go_type_name}Array"
        end

        render_property_get do |sdk_marshal, property|
          "expand#{sdk_marshal.enqueue(property, $global_expand_queue)}"
        end

        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          var_name
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          # TODO
          raise NotImplementedError
        end
      end

      class StringMapObject < SDKTypeDefinition
        build_ef_func_name do |sdk_marshal, property|
          "#{sdk_marshal.resource}#{property.name.titleize}"
        end

        def build_var_name(property)
          return 't' if property.instance_of? Api::Azure::Type::Tags
          super
        end

        render_property_get

        # TODO: add render property method
        render_property_to_sdk_field do |sdk_marshal, property, var_name|
          next 'tags.Expand(t)' if property.instance_of? Api::Azure::Type::Tags
          # TODO
          #"#{expand_func}(#{var_name})"
        end

        def render_sdk_field_to_property(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          return render_sdk_field_to_property_for_tags(sdk_marshal, property, schema_var_name, resp_var, indentation: indentation) if property.instance_of? Api::Azure::Type::Tags

          # TODO
          raise NotImplementedError
        end

        private

        def render_sdk_field_to_property_for_tags(sdk_marshal, property, schema_var_name, resp_var, indentation: 4)
          # NOTE: We skip tag here on purpose, coding style demands to set tag on function return
          # compile_template 'templates/azure/terraform/schemas/tags_set.erb',
          #                  indentation: indentation,
          #                  input_var: "#{resp_var}.#{go_field_name}",
          #                  output_var: schema_var_name
        end
      end
    end
  end
end
