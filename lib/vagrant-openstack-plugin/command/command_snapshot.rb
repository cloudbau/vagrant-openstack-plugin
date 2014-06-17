require "vagrant"
require "vagrant/action/builder"
require "pathname"
require "vagrant-openstack-plugin/action"


module VagrantPlugins
  module OpenStack
    module Action
      class CommandTakeSnapshot < Vagrant.plugin("2", :command)
        include Vagrant::Action::Builtin

        def execute
          options = {:openstack_snapshot_name => 'snapshot'}
          opts = OptionParser.new do |opts|
            opts.banner = "Enters openstack"
            opts.separator ""
            opts.separator "Usage: vagrant openstack snapshot <vmname> -n <snapshotname>"


            opts.on( '-n', '--name NAME', 'snapshotname' ) do |name|
              options[:openstack_snapshot_name] = name
            end

          end

          # Parse the options
          argv = parse_options(opts)

          return if !argv


          with_target_vms(argv, :reverse => true) do |vm|
            if vm.provider.to_s == VagrantPlugins::OpenStack::Provider.new(nil).to_s
              vm.action(:take_snapshot,options)
            end
          end
        end
      end

    end
  end
end