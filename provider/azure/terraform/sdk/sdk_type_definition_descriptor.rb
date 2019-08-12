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
    module Terraform
      module SDK
        class TypeDefinitionDescriptor
          attr_reader :operation
          attr_reader :typedef_reference

          def initialize(operation, isRequest, reference = nil)
            @operation = operation
            @isRequest = isRequest
            @typedef_reference = reference || (@isRequest ? '/' : '')
          end

          def clone(typedef_reference = nil)
            TypeDefinitionDescriptor.new @operation, @isRequest, (typedef_reference || @typedef_reference)
          end

          def type_definitions
            return @operation.request if @isRequest
            @operation.response.has_key?(@typedef_reference) ? @operation.response : @operation.request
          end

          def type_definition
            type_definitions[@typedef_reference]
          end

          def go_type_name
            return type_definition.go_type_name unless type_definition.nil?
            nil
          end

          def go_field_name
            return type_definition.go_field_name unless type_definition.nil?
            nil
          end
        end
      end
    end
  end
end
