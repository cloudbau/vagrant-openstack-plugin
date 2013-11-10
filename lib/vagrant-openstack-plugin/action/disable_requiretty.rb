require 'vagrant-openstack-plugin/helper'
require 'log4r'

module VagrantPlugins
  module OpenStack
    module Action
      class DisableRequiretty
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new("vagrant_openstack::action::disable_requiretty")
        end

        def call(env)
          @app.call env
          if disable_requiretty?
            @logger.info("Disabling requiretty in /etc/sudoers")
            helper.disable_requiretty
          end
        end

        private
        def helper
          VagrantPlugins::OpenStack::Helper::Machine.new @machine
        end

        def disable_requiretty?
          @machine.provider_config.disable_requiretty == nil ||
             @machine.provider_config.disable_requiretty
        end
      end
    end
  end
end
