module VagrantPlugins
  module OpenStack
    module Action
      class IsSnapshoting
        def initialize(app, env)
          @app = app
        end

        def call(env)
          if env[:machine].id
            infos = env[:openstack_compute].get_server_details(env[:machine].id)
            task = infos.body['server']['OS-EXT-STS:task_state']
            if task == 'image_snapshot' || task == 'image_pending_upload'
              env[:result] = true
            else
              env[:result] = false
            end
          end
          @app.call(env)
        end
      end
    end
  end
end
