# coding: utf-8
require 'log4r'
require 'timeout'

module VagrantPlugins
  module OpenStack
    module Action
      # This action will wait for a machine to reach a specific state or quit by timeout.
      class WaitForTask
        def initialize(app, env, task, timeout)
          @app = app
          @logger = Log4r::Logger.new('vagrant_openstack::action::wait_for_task')
          @task = Array.new(task).flatten
          @timeout = timeout
        end

        def call(env)
          env[:result] = true
          task = get_task(env)

          if @task.include?(task)
            @logger.info("Machine already at task #{ task.to_s }")
          else
            @logger.info("Waiting for machine to reach task...")
            begin
              Timeout.timeout(@timeout) do
                sleep 5 until @task.include?(get_task(env))
              end
            rescue Timeout::Error
              env[:result] = false
            end

            @app.call(env)
          end
        end

        def get_task(env)
          infos = env[:openstack_compute].get_server_details(env[:machine].id)
          infos.body['server']['OS-EXT-STS:task_state']
        end
      end
    end
  end
end
