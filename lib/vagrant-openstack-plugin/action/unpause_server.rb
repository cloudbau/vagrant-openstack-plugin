require "log4r"

module VagrantPlugins
  module OpenStack
    module Action
      # This starts the pause server, if there is one.
      class UnpauseServer
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_openstack::action::unpause_server")
        end

        def call(env)
          if env[:machine].id
            env[:ui].info(I18n.t("vagrant_openstack.unpausing_server"))
            server = env[:openstack_compute].servers.get(env[:machine].id)
            server.unpause
          end

          @app.call(env)
        end
      end
    end
  end
end
