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

require 'api/type'

# Extend type Api::Type
Api::Type.class_eval do
  alias_method :google_validate, :validate
  def validate
    default_order = 10
    default_order = 1 if @name == "name"
    default_order = -1 if @name == "id"
    check :order, type: ::Integer, default: default_order
    check :azure_sdk_references, type: ::Array, item_type: ::String
    google_validate
  end
end

# Extend type Api::Type::Fields
Api::Type::Fields.module_eval do
  attr_reader :order
  attr_reader :sample_value
  attr_reader :azure_sdk_references
end

# Extend certain properties types
Api::Type::Boolean.class_eval do
  def go_type
    'bool'
  end
end

Api::Type::Integer.class_eval do
  def go_type
    'int'
  end
end

Api::Type::Double.class_eval do
  def go_type
    'float64'
  end
end

Api::Type::String.class_eval do
  def go_type
    'string'
  end
end

Api::Type::Array.class_eval do
  def go_type
    '[]interface{}'
  end
end

Api::Type::Enum.class_eval do
  def go_type
    'string'
  end
end

Api::Type::KeyValuePairs.class_eval do
  def go_type
    'map[string]interface{}'
  end
end

Api::Type::Map.class_eval do
  def go_type
    raise 'TBD'
  end
end

Api::Type::NestedObject.class_eval do
  def go_type
    raise '[]interface{}'
  end
end

Api::Type::Time.class_eval do
  def go_type
    raise 'string'
  end
end
