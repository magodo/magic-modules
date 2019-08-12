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

require 'provider/ansible/config'

module Provider
  module Azure
    module Ansible

      class Config < Provider::Ansible::Config
        attr_reader :author
        attr_reader :version_added

        def provider
          Provider::Ansible::Core
        end
  
        def resource_override
          Provider::Azure::Ansible::ResourceOverride
        end
  
        def property_override
          Provider::Azure::Ansible::PropertyOverride
        end

        def validate
          super
          check :author, type: ::String, required: true
          check :version_added, type: ::String, required: true
        end
      end

    end
  end
end
