require "log4r"

module VagrantPlugins
  module OpenStack
    module Action
      # This action reads the SSH info for the machine and puts it into the
      # `:machine_ssh_info` key in the environment.
      class ReadSSHInfo
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_openstack::action::read_ssh_info")
        end

        def call(env)
          env[:machine_ssh_info] = read_ssh_info(env[:openstack_compute], env[:machine])

          @app.call(env)
        end

        def read_ssh_info(openstack, machine)
          return nil if machine.id.nil?

          # Find the machine
          server = openstack.servers.get(machine.id)
          if server.nil?
            # The machine can't be found
            @logger.info("Machine couldn't be found, assuming it got destroyed.")
            machine.id = nil
            return nil
          end

          config = machine.provider_config

          # Print the server network name(s)
          server.addresses.each do |network_name, network_info|
            @logger.debug("OpenStack Network Name: #{network_name}")
          end

          # See if either config.network or config.address_id is set
          # in order to get the instance's IP address.
          #
          # If neither are set, try to determine the network name automatically
          if config.network
            if server.addresses.has_key?(config.network)
              host = server.addresses[config.network].last['addr']
            end
          elsif config.address_id
            if server.addresses.has_key?(config.address_id)
              host = server.addresses[config.address_id].last['addr']
            end
          end

          if host.nil?
            @logger.debug("Neither config.network or config.address_id were used")
            if server.addresses.length == 1
              network_name = server.addresses.keys[0]
              @logger.debug("Using #{network_name} automatically")
              host = server.addresses[network_name].last['addr']
            end
          end

          # If host got this far and is still nil/empty, raise an error or
          # else vagrant will try connecting to localhost which will never
          # make sense in this scenario
          raise Errors::SSHNoValidHost if host.nil? or host.empty?

          # Read the DNS info
          return {
            # Usually there should only be one public IP
            :host => host,
            :port => 22,
            :username => config.ssh_username
          }
        end
      end
    end
  end
end
