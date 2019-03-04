module Provider
  module Azure
    module Terraform
      module Schema

        def go_type(property)
          case property
          when Api::Type::Boolean
            'bool'
          when Api::Type::Enum, Api::Type::String
            'string'
          when Api::Type::KeyValuePairs
            'map[string]interface{}'
          else
            'interface{}'
          end
        end

        def expand_func(property)
          expand_funcs[property.class]
        end

        def expand_funcs
          {
            Api::Type::Boolean => 'utils.Bool',
            Api::Type::String => 'utils.String',
            Api::Azure::Type::Location => "utils.String",
            Api::Azure::Type::Tags => 'expandTags',
          }
        end

        def schema_property_template(property)
          case property
          when Api::Azure::Type::ResourceGroupName
            'templates/azure/terraform/schemas/resource_group_name.erb'
          when Api::Azure::Type::Location
            'templates/azure/terraform/schemas/location.erb'
          when Api::Azure::Type::Tags
            'templates/azure/terraform/schemas/tags.erb'
          when Api::Type::Boolean, Api::Type::Enum, Api::Type::String
            'templates/terraform/schemas/primitive.erb'
          else
            'templates/terraform/schemas/unsupport.erb'
          end
        end

        def schema_property_get_template(property)
          return property.custom_schema_get if property.instance_variable_defined?(:@custom_schema_get) && !property.custom_schema_get.nil?
          case property
          when Api::Azure::Type::Location
            'templates/azure/terraform/schemas/location_get.erb'
          when Api::Type::Boolean, Api::Type::Enum, Api::Type::String, Api::Type::KeyValuePairs
            'templates/terraform/schemas/basic_get.erb'
          else
            'templates/terraform/schemas/unsupport.erb'
          end
        end

        def schema_property_set_template(property)
          return property.custom_schema_set if property.instance_variable_defined?(:@custom_schema_set) && !property.custom_schema_set.nil?
          case property
          when Api::Azure::Type::Location
            'templates/azure/terraform/schemas/location_set.erb'
          when Api::Azure::Type::Tags
            'templates/azure/terraform/schemas/tags_set.erb'
          when Api::Type::Boolean, Api::Type::Enum, Api::Type::String
            'templates/terraform/schemas/basic_set.erb'
          else
            'templates/terraform/schemas/unsupport.erb'
          end
        end

        def property_to_sdk_object_template(sdk_type_defs, api_path)
          case sdk_type_defs[api_path]
          when Api::Azure::SDKTypeDefinition::BooleanObject, Api::Azure::SDKTypeDefinition::StringObject
            'templates/azure/terraform/sdktypes/property_to_sdkprimitive.erb'
          when Api::Azure::SDKTypeDefinition::EnumObject
            'templates/azure/terraform/sdktypes/property_to_sdkenum.erb'
          when Api::Azure::SDKTypeDefinition::ComplexObject
            'templates/azure/terraform/sdktypes/property_to_sdkobject.erb'
          else
            'templates/azure/terraform/sdktypes/unsupport.erb'
          end
        end

        def sdk_object_to_property_template(sdk_type_defs, api_path)
          return 'templates/azure/terraform/sdktypes/sdkobject_to_property.erb' if api_path == ""
          case sdk_type_defs[api_path]
          when Api::Azure::SDKTypeDefinition::BooleanObject, Api::Azure::SDKTypeDefinition::StringObject
            'templates/azure/terraform/sdktypes/sdkprimitive_to_property.erb'
          when Api::Azure::SDKTypeDefinition::EnumObject
            'templates/azure/terraform/sdktypes/sdkenum_to_property.erb'
          when Api::Azure::SDKTypeDefinition::ComplexObject
            'templates/azure/terraform/sdktypes/sdkobject_to_property.erb'
          else
            'templates/azure/terraform/sdktypes/unsupport.erb'
          end
        end

      end
    end
  end
end
