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

require 'provider/config'

module Provider
  module Azure
    module Terraform

      class Config < Provider::Config
        def provider
          Provider::Terraform
        end

        def resource_override
          Provider::Azure::Terraform::ResourceOverride
        end

        def property_override
          Provider::Azure::Terraform::PropertyOverride
        end
      end

    end
  end
end
