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
        class MarshalDescriptor
          attr_reader :package
          attr_reader :resource
          attr_reader :queue
          attr_reader :sdktype
          attr_reader :properties

          def initialize(package, resource, queue, sdktype, properties)
            @package = package
            @resource = resource
            @queue = queue
            @sdktype = sdktype
            @properties = properties
          end

          def clone(typedef_reference = nil, properties = nil)
            sdktype = @sdktype.clone(typedef_reference)
            MarshalDescriptor.new @package, @resource, @queue, sdktype, (properties || @properties)
          end

          def enqueue(property, global_queue)
            ef_desc = ExpandFlattenDescriptor.new(property, self)
            exist = @queue.find{|q| q.equals?(ef_desc)}
            global_exist = global_queue.find{|q| q.equals?(ef_desc)}
            @queue << ef_desc if global_exist.nil?
            global_queue << ef_desc if global_exist.nil?
            (exist || ef_desc).func_name
          end
        end
      end
    end
  end
end
