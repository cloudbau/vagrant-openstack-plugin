module VagrantPlugins
module OpenStack
    module Action
      class MessageSnapshotInProgress
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t("vagrant_openstack.snapshot_in_progress"))
          @app.call(env)
        end
      end
    end
  end
end
