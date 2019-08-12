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

require 'provider/core'
require 'api/object'

module Provider
  module Azure
    class ExampleReference < Api::Object
      attr_reader :product
      attr_reader :example

      def validate
        super
        check :product, type: ::String
        check :example, type: ::String, required: true
      end
    end

    class Example < Api::Object
      attr_reader :resource
      attr_reader :description
      attr_reader :prerequisites
      attr_reader :properties

      def validate
        super
        check :resource, type: ::String, required: true
        check :description, type: ::String
        check :prerequisites, type: ::Array, item_type: ExampleReference
        check :properties, type: ::Hash, required: true
      end
    end
  end
end
