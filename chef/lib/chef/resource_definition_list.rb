#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
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

require 'chef/mixin/from_file'
require 'chef/resource_definition'

class Chef
  class ResourceDefinitionList
    include Chef::Mixin::FromFile

    attr_accessor :defines
    attr_reader :run_context

    def initialize(run_context)
      @defines = Hash.new
      @run_context = run_context
    end

    def define(resource_name, prototype_params=nil, &block)
      unless resource_name.kind_of?(Symbol)
        raise ArgumentError, "You must use a symbol when defining a new resource!"
      end
      resource = ::Chef::Resource.build_resource_class(resource_name.to_s, nil, run_context) do
        actions :synthetic
        default_action :synthetic
        # emulate array to mimic params behaviour
        define_method "[]" do |m|
          send(m)
        end
        prototype_params.each do |param_name, param|
          attribute param_name, :default => param
        end
      end

      provider = ::Chef::Provider.build_provider_class(resource_name.to_s, nil, run_context) do
        alias :params :new_resource
        self.action(:synthetic,  &block)
      end

      true
    end
  end
end
