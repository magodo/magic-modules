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

require 'provider/azure/terraform/config'
require 'provider/azure/terraform/custom_code'
require 'provider/azure/terraform/helpers'
require 'provider/azure/terraform/schema'
require 'provider/azure/terraform/sub_template'
require 'provider/azure/terraform/sdk/sdk_type_definition_descriptor'
require 'provider/azure/terraform/sdk/sdk_marshal_descriptor'
require 'provider/azure/terraform/sdk/expand_flatten_descriptor'
require 'provider/azure/terraform/sdk/sub_template'
require 'provider/azure/terraform/sdk/helpers'
require 'provider/azure/terraform/example/sub_template'
require 'provider/azure/terraform/example/helpers'
require 'provider/azure/terraform/acctest/sub_template'

require 'provider/azure/terraform/resource_override'
require 'provider/azure/terraform/property_override'

module Provider
  module Azure
    module TerraformExtension
      include Provider::Azure::Terraform::Helpers
      include Provider::Azure::Terraform::Schema
      include Provider::Azure::Terraform::SubTemplate
      include Provider::Azure::Terraform::SDK::SubTemplate
      include Provider::Azure::Terraform::SDK::Helpers
      include Provider::Azure::Terraform::Example::SubTemplate
      include Provider::Azure::Terraform::Example::Helpers
      include Provider::Azure::Terraform::AccTest::SubTemplate

      def initialize(config, api, start_time)
        super
        @provider = 'terraform'
      end

      def azure_tf_types(map)
        map[Api::Azure::Type::ResourceReference] = 'schema.TypeString'
        map[Api::Azure::Type::BooleanEnum] = 'schema.TypeBool'
        map[Api::Azure::Type::ISO8601DateTime] = 'schema.TypeString'
        map[Api::Azure::Type::ISO8601Duration] = 'schema.TypeString'
        map['Api::Azure::Type::ResourceReference'] = 'schema.TypeString'
        map['Api::Type::Integer'] = 'schema.TypeInt'
        map
      end

      def azure_generate_resource(data)
        dir = "azurerm"
        target_folder = File.join(data.output_folder, dir)

        name = data.object.name.underscore
        product_name = data.product.name.underscore
        filepath = File.join(target_folder, "resource_arm_#{name}.go")

        data.generate('templates/azure/terraform/resource.erb', filepath, self)
        generate_documentation(data)
      end

      def azure_generate_documentation(data)
        target_folder = data.output_folder
        target_folder = File.join(target_folder, 'website', 'docs', 'r')
        FileUtils.mkpath target_folder

        name = data.object.name.underscore
        product_name = data.product.name.underscore
        filepath = File.join(target_folder, "#{name}.html.markdown")

        data.generate('templates/azure/terraform/resource.html.markdown.erb', filepath, self)
      end

      def azure_generate_resource_tests(data)
        dir = "azurerm"
        target_folder = File.join(data.output_folder, dir)

        name = data.object.name.underscore
        product_name = data.product.name.underscore
        filepath = File.join(target_folder, "resource_arm_#{name}_test.go")

        data.product = data.product.name
        data.resource_name = data.object.name.camelize(:upper)
        data.generate('templates/azure/terraform/test_file.go.erb', filepath, self)
      end

      def compile_datasource(data)
        dir = 'azurerm'
        target_folder = File.join(data.output_folder, dir)
        FileUtils.mkpath target_folder

        name = data.object.name.underscore
        product_name = data.product.name.underscore

        filepath = File.join(target_folder, "data_source_#{name}.go")
        data.generate('templates/azure/terraform/datasource.erb', filepath, self)

        filepath = File.join(target_folder, "data_source_#{name}_test.go")
        data.generate('templates/azure/terraform/datasource_test.go.erb', filepath, self)

        target_folder = File.join(data.output_folder, 'website', 'docs', 'd')
        FileUtils.mkpath target_folder
        filepath = File.join(target_folder, "#{name}.html.markdown")
        data.generate('templates/azure/terraform/datasource.html.markdown.erb', filepath, self)
      end

      def build_ef_func_name(resource_name, type_name, compact: false)
        result = resource_name + type_name
        # compact resource_name and type_name with potential overlapping
        if compact
          (0...type_name.length).each do |idx|
            if resource_name.end_with? type_name[0..idx]
              result = resource_name + type_name[idx + 1..-1]
            end
          end
        end
        result
      end
    end
  end
end
