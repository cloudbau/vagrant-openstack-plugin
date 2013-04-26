require "fog"
require "log4r"

module VagrantPlugins
  module OpenStack
    module Action
      # This action connects to OpenStack, verifies credentials work, and
      # puts the OpenStack connection object into the `:openstack_compute` key
      # in the environment.
      class ConnectOpenStack
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_openstack::action::connect_openstack")
        end

        def call(env)
          # Get the configs
          config   = env[:machine].provider_config
          api_key  = config.api_key
          endpoint = config.endpoint
          username = config.username

          @logger.info("Connecting to OpenStack...")
          env[:openstack_compute] = Fog::Compute.new({
            :provider => :openstack,
            :openstack_username => username,
            :openstack_api_key => api_key,
            :openstack_auth_url => endpoint
          })

          if config.network
            env[:openstack_network] = Fog::Network.new({
              :provider => :openstack,
              :openstack_username => username,
              :openstack_api_key => api_key,
              :openstack_auth_url => endpoint
            })
          end

          @app.call(env)
        end
      end
    end
  end
end
