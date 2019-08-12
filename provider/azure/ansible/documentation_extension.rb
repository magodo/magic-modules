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

module Provider
  module Azure
    module Ansible
      module DocumentationExtension

        def azure_documentation_for_property(prop, object, is_data_source = false)
          required = prop.required && !prop.default_value && !is_location?(prop) ? true : nil
          {
            azure_python_variable_name(prop, object.azure_sdk_definition.create) => {
              'description' => [
                (is_data_source && is_tags?(prop) ? "Limit results by providing a list of tags. Format tags as 'key' or 'key:value'." : format_description(prop.description)),
                (resourceref_description(prop) if prop.is_a?(Api::Type::ResourceRef) && !prop.resource_ref.readonly),
                (azure_resource_ref_description(prop) if prop.is_a?(Api::Azure::Type::ResourceReference))
              ].flatten.compact,
              'required' => required,
              'default' => (prop.default_value.to_s.underscore if prop.default_value),
              'type' => azure_python_type(prop),
              'choices' => (prop.values.map{|v| v.to_s.underscore} if prop.is_a?(Api::Type::Enum)),
              'aliases' => prop.aliases,
              'suboptions' => (
                if (prop.is_a?(Api::Type::NestedObject) || prop.is_a?(Api::Type::Array) && prop.item_type.is_a?(Api::Type::NestedObject)) && prop.nested_properties?
                  prop.nested_properties.reject(&:output).map { |p| azure_documentation_for_property(p, object) }
                                        .reduce({}, :merge)
                end
              )
            }.reject { |_, v| v.nil? }
          }
        end

        def azure_returns_for_property(prop, object)
          type = azure_python_type(prop) || 'str'
          type = 'str' if type == 'path' || prop.is_a?(Api::Azure::Type::ResourceReference)
          type = 'dict' if prop.is_a?(Api::Azure::Type::Tags)
          type = 'complex' if prop.is_a?(Api::Type::NestedObject) \
                              || (prop.is_a?(Api::Type::Array) \
                              && prop.item_type.is_a?(Api::Type::NestedObject))
          sample = prop.document_sample_value || prop.sample_value
          sample = sample.to_s.underscore if sample.is_a? Symbol
          {
            azure_python_variable_name(prop, object.azure_sdk_definition.create) => {
              'description' => format_description(prop.description),
              'returned' => 'always',
              'type' => type,
              'sample' => sample,
              'contains' => (
                if prop.nested_properties?
                  prop.nested_properties.map { |p| azure_returns_for_property(p, object) }
                                        .reduce({}, :merge)
                end
              )
            }.reject { |_, v| v.nil? }
          }
        end

        def azure_autogen_notic_contrib
          ['Please read more about how to change this file at',
           'https://github.com/Azure/magic-module-specs']
        end

        private

        def azure_resource_ref_description(prop)
          [
            "It can be the #{prop.resource_type_name} name which is in the same resource group.",
            "It can be the #{prop.resource_type_name} ID. e.g., #{prop.document_sample_value || prop.sample_value}.",
            "It can be a dict which contains C(name) and C(resource_group) of the #{prop.resource_type_name}."
          ]
        end

      end
    end
  end
end
