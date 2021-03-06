#
# Copyright Peter Donald
#
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
#

include Chef::Asadmin

use_inline_resources

action :set do
  args = []
  args << 'set-web-env-entry'
  args << '--name' << new_resource.name
  args << '--type' << new_resource.type
  args << '--description' << "'#{new_resource.description}'" if new_resource.description
  if new_resource.value.nil?
    args << '--ignoreDescriptorItem'
  else
    args << "'--value=#{new_resource.value}'"
  end
  args << new_resource.webapp

  execute "asadmin_set-web-env-entry #{new_resource.webapp} --name #{new_resource.name}" do
    not_if "#{asadmin_command("list-web-env-entry #{new_resource.webapp}")} | grep -F -x -- '#{new_resource.name} (#{new_resource.type}) #{new_resource.value} ignoreDescriptorItem=#{new_resource.value.nil?} //(#{new_resource.description || 'description not specified'})'", :timeout => node['glassfish']['asadmin']['timeout'] + 5
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node['os'] == 'windows'
    group new_resource.system_group unless node['os'] == 'windows'
    command asadmin_command(args.join(' '))
  end
end

action :unset do
  args = []
  args << 'unset-web-env-entry'
  args << '--name' << new_resource.name
  args << new_resource.webapp

  execute "asadmin_unset-web-env-entry #{new_resource.name}" do
    only_if "#{asadmin_command("list-web-env-entry #{new_resource.webapp}")} | grep -F -x -- '#{new_resource.name}'", :timeout => node['glassfish']['asadmin']['timeout'] + 5
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node['os'] == 'windows'
    group new_resource.system_group unless node['os'] == 'windows'
    command asadmin_command(args.join(' '))
  end
end
