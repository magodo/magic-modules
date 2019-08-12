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
      module Module
        module SubTemplate
          def build_class_instance_variable_init(sdk_operation, object, indentation = 8)
            result = compile 'templates/azure/ansible/module/class_instance_variable_init.erb', 1
            indent result, indentation
          end

          def build_response_properties_update(properties, sdk_response_def, indentation = 16)
            result = compile 'templates/azure/ansible/module/response_properties_update.erb', 1
            indent_list result, indentation
          end
        end
      end
    end
  end
end