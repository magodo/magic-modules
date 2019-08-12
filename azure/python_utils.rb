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

require 'google/python_utils'

module Azure
  module PythonUtils
    include Google::PythonUtils

    # Azure extended `python_literal` function (see 'google/python_utils.rb')
    # It will treat Azure SDK enumerations differently
    def azure_python_literal(value, **opts)
      return "'#{value.to_s.underscore}'" if value.is_a?(Symbol)
      python_literal(value, opts)
    end

    # Get the python variable name of a property
    # If we can find the corresponding SDK definition, we use its `python_variable_name`, otherwise we `underscore` the property's name
    def azure_python_variable_name(property, sdk_op_def)
      sdk_ref = get_applicable_reference(property.azure_sdk_references, sdk_op_def.request)
      return property.out_name.underscore if sdk_ref.nil?
      python_var = get_sdk_typedef_by_references(property.azure_sdk_references, sdk_op_def.request).python_variable_name
      return property.out_name.underscore if python_var.nil?
      python_var
    end

  end
end
