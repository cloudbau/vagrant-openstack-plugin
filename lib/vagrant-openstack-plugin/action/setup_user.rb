require 'vagrant-openstack-plugin/helper'
require 'log4r'

module VagrantPlugins
  module OpenStack
    module Action
      class SetupUser
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new("vagrant_openstack::action::sync_folders")
        end

        def call(env)
          @app.call env
#          env[:ui].info(I18n.t("vagrant_openstack.waiting_for_build"))
          env[:ui].info("Setting up ssh user")

          if user != 'root'
            helper.add_user user
            helper.setup_sudo user
            helper.create_ssh_dir user
            helper.copy_authorized_keys user
          end
          helper.disable_sudo_requiretty
          env[:machine].ssh_info[:username] = user

          #user is setup, let's use it from now on
        end

        private
        def helper
          VagrantPlugins::OpenStack::Helper::Machine.new @machine
        end

        def user
          @machine.config.ssh.username || 'vagrant'
        end
      end
    end
  end
end
