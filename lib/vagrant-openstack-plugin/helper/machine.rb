require 'log4r'

module VagrantPlugins
  module OpenStack
    module Helper
      class Machine
        attr_accessor :machine

        def initialize(machine)
          @machine = machine
          @logger = Log4r::Logger.new("vagrant_openstack::action::read_state")
        end

        def add_user(user)
          as_root %Q(
            if ! (grep #{user} /etc/passwd); then
              useradd -m -s /bin/bash #{user};
            fi
          )
        end

        def setup_sudo(user)
          as_root %Q(
            if ! (grep #{user} /etc/sudoers); then
              echo "#{user} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers;
            fi
          )
        end

        def create_ssh_dir(user)
          as_root "su #{user} -c 'mkdir -p ~/.ssh'"
        end

        def copy_authorized_keys(user)
          as_root %Q(
            cp ~/.ssh/authorized_keys /home/#{user}/.ssh
            chown #{user} /home/#{user}/.ssh/authorized_keys
          )
        end

        def disable_sudo_requiretty
          as_root %q(
            sed -i'.bk' -e 's/^\\\(Defaults\s\+requiretty\\\)/# \1/' /etc/sudoers
          )
        end

        private

        def as_root(command)
          @logger.debug "Running command as root: '#{command}'"
          user = machine.config.ssh.username
          machine.config.ssh.username = 'root'
          machine.communicate.execute command
          machine.config.ssh.username = user
        end
      end
    end
  end
end
