require 'provider/azure/ansible/helpers'
require 'provider/azure/ansible/sub_template'
require 'provider/azure/ansible/sdk/helpers'
require 'provider/azure/ansible/module/sub_template'
require 'provider/azure/ansible/sdk/sub_template'
require 'provider/azure/ansible/example/sub_template'

module Provider
  module Azure
    module Ansible
      include Provider::Azure::Ansible::Helpers
      include Provider::Azure::Ansible::SDK::Helpers
      include Provider::Azure::Ansible::SubTemplate
      include Provider::Azure::Ansible::Module::SubTemplate
      include Provider::Azure::Ansible::SDK::SubTemplate
      include Provider::Azure::Ansible::Example::SubTemplate
    end
  end
end