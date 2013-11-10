require 'log4r'

module VagrantPlugins
  module OpenStack
    module Helper
      class Machine
        attr_accessor :machine

        def initialize(machine)
          @machine = machine
          @logger = Log4r::Logger.new("vagrant_openstack::helper::machine")
        end

        def disable_requiretty
          exec %q(
            sed -i'.bk' -e 's/^\\\(Defaults\s\+requiretty\\\)/# \1/' /etc/sudoers
          )
        end

        private
        def exec(command)
          machine.communicate.execute command
        end
      end
    end
  end
end
