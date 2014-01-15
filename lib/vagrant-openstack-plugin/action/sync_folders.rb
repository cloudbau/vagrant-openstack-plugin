require "log4r"

require "vagrant/util/subprocess"

module VagrantPlugins
  module OpenStack
    module Action
      # This middleware uses `rsync` to sync the folders over to the
      # remote instance.
      class SyncFolders
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_openstack::action::sync_folders")
        end

        def call(env)
          @app.call(env)

          ssh_info = env[:machine].ssh_info

          env[:machine].config.vm.synced_folders.each do |id, data|

            # ignore disabled shared folders
            if data[:disabled]
              @logger.info "Not syncing disabled folder: #{data[:hostpath]} => #{data[:guestpath]}"
              next
            end

            hostpath  = File.expand_path(data[:hostpath], env[:root_path])
            guestpath = data[:guestpath]

            # Make sure there is a trailing slash on the host path to
            # avoid creating an additional directory with rsync
            hostpath = "#{hostpath}/" if hostpath !~ /\/$/

            env[:ui].info(I18n.t("vagrant_openstack.rsync_folder",
                                :hostpath => hostpath,
                                :guestpath => guestpath))

            # Create the guest path
            env[:machine].communicate.sudo("mkdir -p '#{guestpath}'")
            env[:machine].communicate.sudo(
              "chown #{ssh_info[:username]} '#{guestpath}'")

            # Rsync over to the guest path using the SSH info
            if env[:machine].config.ssh.proxy_command
              proxy_cmd = "-o ProxyCommand='#{env[:machine].config.ssh.proxy_command}'"
            else
              proxy_cmd = ''
            end

            # poor workaround for poor ipv6 handling of rsync
            if ssh_info[:host].include? ':'
              user_at_host = "[#{ssh_info[:username]}@#{ssh_info[:host]}]"
            else
              user_at_host = ssh_info[:username] + "@" + ssh_info[:host]
            end

            # Since Vagrant 1.4 this may be an array
            ssh_key_paths = ssh_info[:private_key_path].is_a?(Array) ? ssh_info[:private_key_path] : [ ssh_info[:private_key_path] ]
            ssh_keys = ssh_key_paths.map {|p| "-i '#{p}'"}.join(" ")
 
            command = [
              "rsync", "--verbose", "--archive", "-z", "--delete",
              "--exclude", ".vagrant/",
              "-e", "ssh -p #{ssh_info[:port]} -o StrictHostKeyChecking=no #{proxy_cmd} #{ssh_keys}",
              hostpath,
              user_at_host + ":" + guestpath]

            r = Vagrant::Util::Subprocess.execute(*command)
            if r.exit_code != 0
              raise Errors::RsyncError,
                :guestpath => guestpath,
                :hostpath => hostpath,
                :stderr => r.stderr
            end
          end
        end
      end
    end
  end
end
