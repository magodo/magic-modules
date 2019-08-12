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
      module Example
        module Helpers
          def generate_info_assert_list(example_name)
            example = get_example_by_names(example_name)
            asserts = ["- output['items'][0]['id'] != None"]
            example.properties.each_key do |p|
              asserts << "- output['items'][0]['#{p.underscore}'] != None"
            end
            asserts
          end
        end
      end
    end
  end
end
