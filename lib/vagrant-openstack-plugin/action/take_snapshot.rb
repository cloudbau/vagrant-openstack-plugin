require "log4r"

module VagrantPlugins
  module OpenStack
    module Action
      # This reboots a running server, if there is one.
      class TakeSnapshot
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_openstack::action::take_snapshot")
        end

        def call(env)
          if env[:machine].id
            env[:ui].info(I18n.t("vagrant_openstack.snapshoting_server"))
            infos = env[:openstack_compute].get_server_details(env[:machine].id)
            env[:openstack_compute].create_image(env[:machine].id,env[:openstack_snapshot_name] || 'snapshot')

          end

          @app.call(env)
        end
      end
    end
  end
end
