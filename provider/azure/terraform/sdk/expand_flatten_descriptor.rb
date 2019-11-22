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

require 'provider/azure/terraform/sdk/sdk_type_definition_descriptor'

module Provider
  module Azure
    module Terraform
      module SDK
        class ExpandFlattenDescriptor
          attr_reader :func_name
          attr_reader :property
          attr_reader :sdkmarshal

          def initialize(property, sdkmarshal)
            @property = property
            @sdkmarshal = sdkmarshal
            @func_name = build_func_name sdkmarshal.sdktype, property
            #@func_name = @sdkmarshal.sdktype.go_type_name
          end

          def build_func_name(sdktype, property)
            # For ArrayObject needs expand/flatten, since the `go_type_name` indicates the elements'
            # type, to avoid naming conflict with ComplexObject, we should name the func_name with `Array` suffix.
            return "#{sdktype.go_type_name}Array" if property.instance_of?(Api::Type::Array)

            # TODO: this will very likely conflict if multiple file defined this method inside same package
            return 'convertStringToDate' if property.instance_of?(Api::Azure::Type::ISO8601DateTime)

            sdktype.go_type_name
          end

          # This function compares the structure (hierarchical structure, declared type and name) of prop1 and prop2.
          # The major target is to distinguish whether two complex properties could share the same expand/flatten (ef) function.
          def equals?(other)
            return false if @sdkmarshal.sdktype.go_type_name != other.sdkmarshal.sdktype.go_type_name
            return false unless property_structure_equals? @property, other.property
            true
          end

          private

          def property_structure_equals?(prop1, prop2, verify_name = false)
            return false if verify_name && prop1.name != prop2.name
            return false if prop1.class.name != prop2.class.name
            subprops1 = sub_properties(prop1).sort_by!(&:name)
            subprops2 = sub_properties(prop2).sort_by!(&:name)
            return false if subprops1.size != subprops2.size
            subprops1.each_index do |i|
              return false unless property_structure_equals?(subprops1[i], subprops2[i], true)
            end
            true
          end

          def sub_properties(property)
            return property.properties if property.is_a?(Api::Type::NestedObject)
            return property.item_type.properties if property.is_a?(Api::Type::Array) && property.item_type.is_a?(Api::Type::NestedObject)
            return property.value_type.properties if property.is_a?(Api::Type::Map)
            []
          end
        end
      end
    end
  end
end
