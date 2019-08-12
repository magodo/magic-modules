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

require 'provider/azure/example/example'

module Provider
  module Azure
    module Core

      def get_example_by_reference(reference)
        get_example_by_names reference.example, reference.product
      end

      def get_example_by_names(example_name, product_name = nil)
        spec_dir = File.dirname(@config.config_file)
        product_name ||= File.basename(spec_dir)
        example_yaml = File.join(File.dirname(spec_dir), product_name, 'examples', @provider, "#{example_name}.yaml")
        example = Google::YamlValidator.parse(File.read(example_yaml))
        raise "#{example_yaml}(#{example.class}) is not Provider::Azure::Example" unless example.is_a?(Provider::Azure::Example)
        example.validate
        example
      end

      def get_custom_template_path(template_path)
        return nil if template_path.nil?
        spec_dir = File.dirname(@config.config_file)
        File.join(spec_dir, template_path)
      end

    end
  end
end
