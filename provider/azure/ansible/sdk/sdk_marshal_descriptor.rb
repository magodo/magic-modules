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
      module SDK

        class MarshalDescriptor
          attr_reader :properties
          attr_reader :operation
          attr_reader :parent_reference
          attr_reader :marshalled_references
          attr_reader :input
          attr_reader :output

          def initialize(properties, sdk_operation, input, output, parent_sdk_reference = '/', marshalled = nil)
            @properties = properties
            @operation = sdk_operation
            @input = input
            @output = output
            @parent_reference = parent_sdk_reference
            @marshalled_references = marshalled || { '/' => @output }
          end

          def add_marshalled_reference(reference, expression)
            @marshalled_references[reference] = expression
          end

          def create_child_descriptor(property, sdk_reference, sdk_type)
            input_expression = "#{@input}['#{sdk_type.python_field_name}']"
            MarshalDescriptor.new property.nested_properties, @operation, input_expression, @output, sdk_reference, @marshalled_references
          end
        end

      end
    end
  end
end
