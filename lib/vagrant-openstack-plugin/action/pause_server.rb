require "log4r"

module VagrantPlugins
  module OpenStack
    module Action
      # This pauses a running server, if there is one.
      class PauseServer
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_openstack::action::pause_server")
        end

        def call(env)
          if env[:machine].id
            env[:ui].info(I18n.t("vagrant_openstack.pausing_server"))
            server = env[:openstack_compute].servers.get(env[:machine].id)
            server.pause
          end

          @app.call(env)
        end
      end
    end
  end
end
