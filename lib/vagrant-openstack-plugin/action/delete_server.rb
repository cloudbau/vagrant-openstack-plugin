require 'vagrant/util/retryable'
require 'timeout'

require "log4r"

module VagrantPlugins
  module OpenStack
    module Action
      # This deletes the running server, if there is one.
      class DeleteServer
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_openstack::action::delete_server")
        end

        def call(env)
          machine = env[:machine]
          id = machine.id || (env[:openstack_compute].servers.all( :name => machine.name ).length == 1 and
                              env[:openstack_compute].servers.all( :name => machine.name ).first.id)

          if id
            env[:ui].info(I18n.t("vagrant_openstack.deleting_server"))

            # TODO: Validate the fact that we get a server back from the API.
            server = env[:openstack_compute].servers.get(id)
            if server
              # get volumes before destroying server
              volumes = server.volume_attachments

              ip = server.floating_ip_address

              retryable(:on => Timeout::Error, :tries => 20) do
                # If we're interrupted don't worry about waiting
                next if env[:interrupted]

                begin
                  server.destroy if server
                  status = Timeout::timeout(10) {
                    while server.reload
                      sleep(1)
                    end
                  }
                rescue RuntimeError => e
                  # If we don't have an error about a state transition, then
                  # we just move on.
                  raise if e.message !~ /should have transitioned/
                  raise Errors::ServerNotDestroyed
                rescue Fog::Compute::OpenStack::NotFound
                  # If we don't have a server anymore we should be done here just continue on
                end
              end

              if machine.provider_config.floating_ip_pool && machine.provider_config.floating_ip.to_s == 'auto'
                address = env[:openstack_compute].list_all_addresses.body["floating_ips"].find{|i| i["ip"] == ip}
                if address
                  env[:openstack_compute].release_address(address["id"])
                end
              end

              env[:ui].info(I18n.t("vagrant_openstack.deleting_volumes"))
              volumes.each do |compute_volume|
                volume = env[:openstack_volume].volumes.get(compute_volume["id"])
                if volume
                  env[:ui].info("Deleting volume: #{volume.display_name}")
                  begin
                    volume.destroy
                  rescue Excon::Errors::Error => e
                    raise Errors::VolumeBadState, :volume => volume.display_name, :state => e.message
                  end
                end
              end
            end
          else
            env[:ui].info(I18n.t("vagrant_openstack.not_created"))
          end

          @app.call(env)
        end
      end
    end
  end
end
