require "log4r"

module VagrantPlugins
  module OpenStack
    module Action
      # This starts a suspended server, if there is one.
      class ResumeServer
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_openstack::action::resume_server")
        end

        def call(env)
          if env[:machine].id
            env[:ui].info(I18n.t("vagrant_openstack.resuming_server"))
            server = env[:openstack_compute].servers.get(env[:machine].id)
            server.resume
          end

          @app.call(env)
        end
      end
    end
  end
end
