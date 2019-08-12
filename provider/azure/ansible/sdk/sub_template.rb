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

        module SubTemplate
          def build_sdk_method_invocation(sdk_client, sdk_op_def, indentation = 12)
            result = compile 'templates/azure/ansible/sdk/method_invocation.erb', 1
            indent result, indentation
          end

          def build_property_normalization(property, sdk_marshal)
            result = compile property_normalization_template(property), 1
          end

          def build_sdk_reference_assignment(input_expression, reference, sdk_marshal, indentation = 0)
            result = compile 'templates/azure/ansible/sdktypes/reference_assignment.erb', 1
            indent result, indentation
          end

          def build_property_to_sdk_object(sdk_marshal, indentation = 0)
            result = compile 'templates/azure/ansible/sdktypes/property_to_sdkobject.erb', 1
            indent result, indentation
          end

          def build_property_inline_response_format(property, sdk_operation, indentation = 12)
            template = get_custom_template_path(property.inline_custom_response_format)
            template ||= 'templates/azure/ansible/sdktypes/property_inline_response_format.erb'
            result = compile template, 1
            indent result, indentation
          end
        end

      end
    end
  end
end
