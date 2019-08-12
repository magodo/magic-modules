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

require 'api/object'
require 'api/azure/sdk_type_definition'

module Api
  module Azure
    class SDKOperationDefinition < Api::Object
      attr_reader :go_func_name
      attr_reader :python_func_name
      attr_reader :async
      attr_reader :request
      attr_reader :response

      def validate
        super
        @request ||= Hash.new
        @response ||= Hash.new

        check :go_func_name, type: ::String, required: true
        check :python_func_name, type: ::String, required: true
        check :async, type: :boolean
        check_ext :request, type: ::Hash, key_type: ::String, item_type: SDKTypeDefinition, required: true
        check_ext :response, type: ::Hash, key_type: ::String, item_type: SDKTypeDefinition, required: true
      end

      def filter_language!(language)
        filter_applicable! @request, language
        filter_applicable!(@response, language) unless @response.nil?
      end

      def merge_overrides!(overrides)
        merge_hash_table!(@request, overrides.request) unless overrides.request.nil?
        merge_hash_table!(@response, overrides.response) unless overrides.response.nil?
      end

      private

      def filter_applicable!(fields, language)
        fields.reject!{|name, value| !value.applicable_to.nil? && !value.applicable_to.include?(language)}
      end

      def merge_hash_table!(fields, overrides)
        overrides.each do |name, value|
          if value.remove
            fields.delete(name)
          elsif !fields.has_key?(name)
            fields[name] = value
          else
            fields[name].merge_overrides! value
          end
        end
      end
    end
  end
end
