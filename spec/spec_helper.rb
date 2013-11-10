require 'ostruct'
require "vagrant-openstack-plugin/config"
require 'vagrant-openstack-plugin/action/setup_user'
require 'rspec/expectations'
require 'shellwords'

RSpec::Matchers.define :be_shell_command do |expected|
  match do |actual|
    Shellwords.split(actual) == Shellwords.split(expected)
  end
end
