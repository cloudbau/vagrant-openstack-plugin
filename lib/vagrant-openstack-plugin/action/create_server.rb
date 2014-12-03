require "fog"
require "log4r"

require 'vagrant/util/retryable'

module VagrantPlugins
  module OpenStack
    module Action
      # This creates the OpenStack server.
      class CreateServer
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_openstack::action::create_server")
        end

        def call(env)
          # Get the configs
          config   = env[:machine].provider_config

          # Find the flavor
          env[:ui].info(I18n.t("vagrant_openstack.finding_flavor"))
          flavor = find_matching(env[:openstack_compute].flavors.all, config.flavor)
          raise Errors::NoMatchingFlavor if !flavor

          # Find the image
          env[:ui].info(I18n.t("vagrant_openstack.finding_image"))
          image = find_matching(env[:openstack_compute].images, config.image)
          raise Errors::NoMatchingImage if !image

          # Figure out the name for the server
          server_name = config.server_name || env[:machine].name

          # Build the options for launching...
          options = {
            :flavor_ref  => flavor.id,
            :image_ref   => image.id,
            :name        => server_name,
            :key_name    => config.keypair_name,
            :metadata    => config.metadata,
            :user_data   => config.user_data,
            :security_groups => config.security_groups,
            :os_scheduler_hints => config.scheduler_hints,
            :availability_zone => config.availability_zone
          }
          
          # Fallback to only one network, otherwise `config.networks` overrides
          unless config.networks
            if config.network
              config.networks = [ config.network ]
            else
              config.networks = []
            end
          end

          # Find networks if provided
          unless config.networks.empty?
            env[:ui].info(I18n.t("vagrant_openstack.finding_network"))
            options[:nics] = Array.new
            config.networks.each_with_index do |os_network_name, i|

              # Use the configured OpenStack network, if it exists.
              os_network = find_matching(env[:openstack_network].networks, os_network_name)
              if os_network
                current = { :net_id => os_network.id }

                # Match the OpenStack network to a corresponding
                # config.vm.network option.  If there is one, use that for its
                # IP address.
                config_network = env[:machine].config.vm.networks[i]
                if config_network
                  ip_address = config_network[1][:ip]
                  current[:v4_fixed_ip] = ip_address if ip_address
                end

                options[:nics] << current
              end
            end
            env[:ui].info("options[:nics]: #{options[:nics]}")
          end
         
          # Output the settings we're going to use to the user
          env[:ui].info(I18n.t("vagrant_openstack.launching_server"))
          env[:ui].info(" -- Flavor: #{flavor.name}")
          env[:ui].info(" -- Image: #{image.name}")
          env[:ui].info(" -- Name: #{server_name}")
          config.networks.each do |n|
            env[:ui].info(" -- Network: #{n}")
          end
          if config.security_groups
            env[:ui].info(" -- Security Groups: #{config.security_groups}")
          end

          # Create the server
          server = env[:openstack_compute].servers.create(options)

          # Store the ID right away so we can track it
          env[:machine].id = server.id

          # Wait for the server to finish building
          env[:ui].info(I18n.t("vagrant_openstack.waiting_for_build"))
          retryable(:on => Fog::Errors::TimeoutError, :tries => 200) do
            # If we're interrupted don't worry about waiting
            next if env[:interrupted]

            # Set the progress
            env[:ui].clear_line
            env[:ui].report_progress(server.progress, 100, false)

            # Wait for the server to be ready
            begin
              server.wait_for(5) { ready? }
              # Once the server is up and running assign a floating IP if we have one
              floating_ip = config.floating_ip
              # try to automatically associate a floating IP
              if floating_ip && floating_ip.to_sym == :auto
                if config.floating_ip_pool
                  env[:ui].info("Allocating floating IP address from pool: #{config.floating_ip_pool}")
                  address = env[:openstack_compute].allocate_address(config.floating_ip_pool).body["floating_ip"]
                  if address["ip"].nil?
                    raise Errors::FloatingIPNotAllocated
                  else
                    floating_ip = address["ip"]
                  end
                else
                  addresses = env[:openstack_compute].addresses
                  puts addresses
                  free_floating = addresses.find_index {|a| a.fixed_ip.nil?}
                  if free_floating.nil?
                    raise Errors::FloatingIPNotFound
                  else
                    floating_ip = addresses[free_floating].ip
                  end
                end
              end
                
              if floating_ip
                env[:ui].info( "Using floating IP #{floating_ip}")
                floater = env[:openstack_compute].addresses.find { |thisone| thisone.ip.eql? floating_ip }
                floater.server = server
              end
              
              # Process disks if provided
              volumes = Array.new
              if config.disks && !config.disks.empty?
                env[:ui].info(I18n.t("vagrant_openstack.creating_disks"))
                config.disks.each do |disk|
                  volume = env[:openstack_compute].volumes.all.find{|v| v.name ==
                                                          disk["name"] and 
                                                        v.description ==
                                                          disk["description"] and
                                                        v.size ==
                                                          disk["size"] and
                                                        v.ready? }
                  if volume
                    env[:ui].info("re-using volume: #{disk["name"]}")
                    disk["volume_id"] = volume.id
                  else
                    env[:ui].info("creating volume: #{disk["name"]}")
                    disk["volume_id"] = env[:openstack_compute].create_volume(
                                         disk["name"], disk["description"], disk["size"]).\
                                         data[:body]["volume"]["id"]
                    volumes << { :id => disk["volume_id"] }
                  end

                  # mount points are not expected to be meaningful
                  # add useful support if your cloud respects them
                  begin
                    server.attach_volume(disk["volume_id"], "/dev/vd#{("a".."z").to_a[server.volume_attachments.length + 1]}")
                    server.wait_for{ volume_attachments.any?{|vol| vol["id"]==disk["volume_id"]} }
                  rescue Excon::Errors::Error => e
                    raise Errors::VolumeBadState, :volume => disk["name"], :state => e.message
                  end
                end
              end

              # store this so we can use it later
              env[:floating_ip] = floating_ip
              
            rescue RuntimeError => e
              # If we don't have an error about a state transition, then
              # we just move on.
              raise if e.message !~ /should have transitioned/
              raise Errors::CreateBadState, :state => server.state.downcase
            end
          end

          if !env[:interrupted]
            # Clear the line one more time so the progress is removed
            env[:ui].clear_line

            # Wait for SSH to become available
            env[:ui].info(I18n.t("vagrant_openstack.waiting_for_ssh"))
            while true
              begin
                # If we're interrupted then just back out
                break if env[:interrupted]
                break if env[:machine].communicate.ready?
              rescue Errno::ENETUNREACH, Errno::EHOSTUNREACH
              end
              sleep 2
            end

            env[:ui].info(I18n.t("vagrant_openstack.ready"))
          end

          @app.call(env)
        end

        protected

        # This method finds a matching _thing_ in a collection of
        # _things_. This works matching if the ID or NAME equals to
        # `name`. Or, if `name` is a regexp, a partial match is chosen
        # as well.
        def find_matching(collection, name)
          collection.each do |single|
            return single if single.id == name
            return single if single.name == name
            return single if name.is_a?(Regexp) && name =~ single.name
          end

          nil
        end
      end
    end
  end
end
