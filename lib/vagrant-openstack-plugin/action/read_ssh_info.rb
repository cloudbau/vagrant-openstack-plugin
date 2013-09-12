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

          # Print a list of the available networks
          server.addresses.each do |network_name, network_info|
            @logger.debug("OpenStack Network Name: #{network_name}")
          end

          if config.network
            host = server.addresses[config.network].last['addr'] rescue nil
          else
            host = server.addresses[config.address_id].last['addr'] rescue nil
          end

          # If host is still nil, try to find the IP address another way
          if host.nil?
            @logger.debug("Was unable to determine what network to use. Trying to find a valid IP to use.")
            if server.public_ip_addresses.length > 0
              @logger.debug("Public IP addresses available: #{server.public_ip_addresses}")
              if config.floating_ip
                if server.public_ip_addresses.include?(config.floating_ip)
                  @logger.debug("Using the floating IP defined in Vagrantfile.")
                  host = config.floating_ip
                else
                  @logger.debug("The floating IP that was specified is not available to this instance.")
                  raise Errors::FloatingIPNotValid
                end
              else
                host = server.public_ip_address
                @logger.debug("Using the first available public IP address: #{host}.")
              end
            elsif server.private_ip_addresses.length > 0
              @logger.debug("Private IP addresses available: #{server.private_ip_addresses}")
              host = server.private_ip_address
              @logger.debug("Using the first available private IP address: #{host}.")
            end
          end

          # If host got this far and is still nil/empty, raise an error or
          # else vagrant will try connecting to localhost which will never
          # make sense in this scenario
          if host.nil? or host.empty?
            @logger.debug("No valid SSH host could be found.")
            raise Errors::SSHNoValidHost
          end

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
