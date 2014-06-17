module VagrantPlugins
module OpenStack
    module Action
      class MessageSnapshotDone
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t("vagrant_openstack.snapshot_done"))
          @app.call(env)
        end
      end
    end
  end
end
