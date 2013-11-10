require "vagrant-openstack-plugin/config"
require 'vagrant-openstack-plugin/action/disable_requiretty'

require 'shellwords'
require 'ostruct'

require 'rspec/expectations'

RSpec::Matchers.define :be_shell_command do |expected|
  match do |actual|
    Shellwords.split(actual) == Shellwords.split(expected)
  end
end
