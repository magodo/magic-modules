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

require 'provider/terraform/custom_code'

module Provider
  module Azure
    module Terraform

      class CustomCode < Provider::Terraform::CustomCode
        # This code is run after the Read call succeeds and before setting
        # schema attributes. It's placed in the Read function directly
        # without modification.
        attr_reader :post_read

        # This code snippet will be put after all CRUD and expand/flatten functions
        # of a Terraform resource without modification.
        attr_reader :extra_functions

        def validate
          super
          check :post_read, type: ::String
          check :extra_functions, type: ::String
        end
      end

    end
  end
end
