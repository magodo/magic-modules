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
    module ConfigExtension
      # The configuration file path, this should be the root path relative to
      # all API definitions, overrides and examples.
      attr_reader :config_file

      # Azure-extended Provider::Config::validate
      def azure_validate
      end

      # Azure-extended Provider::Config::parse
      def azure_parse(cfg_file)
        @config_file = cfg_file
      end
    end
  end
end
