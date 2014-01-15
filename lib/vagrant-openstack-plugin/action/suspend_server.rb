require "log4r"

module VagrantPlugins
  module OpenStack
    module Action
      # This deletes the running server, if there is one.
      class SuspendServer
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_openstack::action::suspend_server")
        end

        def call(env)
          if env[:machine].id
            env[:ui].info(I18n.t("vagrant_openstack.suspending_server"))
            server = env[:openstack_compute].servers.get(env[:machine].id)
            server.suspend
          end

          @app.call(env)
        end
      end
    end
  end
end
