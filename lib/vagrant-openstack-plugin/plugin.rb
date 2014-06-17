begin
  require "vagrant"
rescue LoadError
  raise "The OpenStack Cloud provider must be run within Vagrant."
end

# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
if Vagrant::VERSION < "1.1.0"
  raise "OpenStack Cloud provider is only compatible with Vagrant 1.1+"
end

module VagrantPlugins
  module OpenStack
    module Action
      class Plugin < Vagrant.plugin("2")
        name "OpenStack Cloud"
        description <<-DESC
      This plugin enables Vagrant to manage machines in OpenStack Cloud.
        DESC

        config(:openstack, :provider) do
          require_relative "config"
          Config
        end

        provider(:openstack, parallel: true) do
          # Setup some things
          OpenStack.init_i18n
          OpenStack.init_logging

          # Load the actual provider
          require_relative "provider"
          Provider
        end

        command "openstack" do
          require_relative "command"
          Command
        end

      end
    end
  end
end
