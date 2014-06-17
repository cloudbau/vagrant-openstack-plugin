require "pathname"

require "vagrant/action/builder"

module VagrantPlugins
  module OpenStack
    module Action
      # Include the built-in modules so we can use them as top-level things.
      include Vagrant::Action::Builtin

      # This action is called when `vagrant destroy` is executed.
      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, DestroyConfirm do |env, b1|
            if env[:result]
              b1.use ConnectOpenStack
              b1.use DeleteServer
            else
              b1.use MessageWillNotDestroy
            end
          end
        end
      end

      # This action is called to read the SSH info of the machine. The
      # resulting state is expected to be put into the `:machine_ssh_info`
      # key.
      def self.action_read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectOpenStack
          b.use ReadSSHInfo
        end
      end

      # This action is called to read the state of the machine. The
      # resulting state is expected to be put into the `:machine_state_id`
      # key.
      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectOpenStack
          b.use ReadState
        end
      end

      # This action is called when `vagrant ssh` is executed.
      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b1|
            unless env[:result]
              b1.use MessageNotCreated
              next
            end

            b1.use SSHExec
          end
        end
      end

      def self.action_ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b1|
            unless env[:result]
              b1.use MessageNotCreated
              next
            end

            b1.use SSHRun
          end
        end
      end

      def self.action_prepare_boot
        Vagrant::Action::Builder.new.tap do |b|
          b.use Provision
          b.use SyncFolders
          b.use WarnNetworks
          b.use SetHostname
        end
      end

      # This action is called when `vagrant up` is executed.
      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use HandleBoxUrl
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b1|
            unless env[:result]
              b1.use action_prepare_boot
              b1.use ConnectOpenStack
              b1.use CreateServer
            else
              b1.use action_resume
            end
          end
        end
      end

      # This action is called when `vagrant provision` is executed.
      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b1|
            unless env[:result]
              b1.use MessageNotCreated
              next
            end

            b1.use ConnectOpenStack
            b1.use Provision
            b1.use SyncFolders
          end
        end
      end

      # This action is called when `vagrant reload` is executed.
      def self.action_reload
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectOpenStack
          b.use Call, IsPaused do |env, b1|
            unless env[:result]
              b1.use Call, IsSuspended do |env2, b2|
                b2.use RebootServer
              end
            end

            b1.use Call, WaitForState, [:active], 120 do |env2, b2|
              unless env2[:result]
                b2.use HardRebootServer
              end
            end
          end
        end
      end

      # This action is called when `vagrant halt` is executed.
      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b1|
            unless env[:result]
              b1.use Call, IsSuspended do |env2, b2|
                if env2[:result]
                  b1.use MessageAlreadySuspended
                  next
                end
              end
            end

            b1.use ConnectOpenStack
            b1.use PauseServer
          end
        end
      end

      # This action is called when `vagrant resume` is executed.
      def self.action_resume
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b1|
            if env[:result]
              b1.use MessageServerRunning
              next
            end

            b1.use ConnectOpenStack
            b1.use ResumeServer
            b1.use SyncFolders
          end
        end
      end

      # This action is called when `vagrant suspend` is executed.
      def self.action_suspend
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b1|
            if env[:result]
              b1.use ConnectOpenStack
              b1.use SuspendServer
            else
              b1.use Call, IsPaused do |env2, b2|
                if env2[:result]
                  b2.use MessageAlreadyPaused
                else
                  b2.use MessageAlreadySuspended
                end
              end
            end
          end
        end
      end

      def self.action_take_snapshot
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b1|
            if env[:result]
              b1.use ConnectOpenStack
              b1.use Call, IsSnapshoting do |env,b2|
                if env[:result]
                  b2.use MessageSnapshotInProgress
                else
                  b2.use TakeSnapshot
                end

                b2.use Call, WaitForTask, [nil], 1200 do |env3, b3|
                  if env3[:result]
                    b3.use MessageSnapshotDone
                  end
                end


              end
            else
              b1.use MessageNotCreated
            end
          end
        end
      end

      # The autoload farm
      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :ConnectOpenStack, action_root.join("connect_openstack")
      autoload :CreateServer, action_root.join("create_server")
      autoload :DeleteServer, action_root.join("delete_server")
      autoload :HardRebootServer, action_root.join("hard_reboot_server")
      autoload :IsCreated, action_root.join("is_created")
      autoload :IsPaused, action_root.join("is_paused")
      autoload :IsSnapshoting, action_root.join("is_snapshoting")
      autoload :IsSuspended, action_root.join("is_suspended")
      autoload :MessageAlreadyCreated, action_root.join("message_already_created")
      autoload :MessageAlreadyPaused, action_root.join("message_already_paused")
      autoload :MessageAlreadySuspended, action_root.join("message_already_suspended")
      autoload :MessageNotCreated, action_root.join("message_not_created")
      autoload :MessageNotSuspended, action_root.join("message_not_suspended")
      autoload :MessageSnapshotDone, action_root.join("message_snapshot_done")
      autoload :MessageSnapshotInProgress, action_root.join("message_snapshot_in_progress")
      autoload :MessageWillNotDestroy, action_root.join("message_will_not_destroy")
      autoload :MessageServerRunning, action_root.join("message_server_running")
      autoload :PauseServer, action_root.join("pause_server")
      autoload :ReadSSHInfo, action_root.join("read_ssh_info")
      autoload :ReadState, action_root.join("read_state")
      autoload :RebootServer, action_root.join("reboot_server")
      autoload :ResumeServer, action_root.join("resume_server")
      autoload :SuspendServer, action_root.join("suspend_server")      
      autoload :SyncFolders, action_root.join("sync_folders")
      autoload :TakeSnapshot, action_root.join("take_snapshot")
      autoload :WaitForState, action_root.join("wait_for_state")
      autoload :WaitForTask, action_root.join("wait_for_task")
      autoload :WarnNetworks, action_root.join("warn_networks")
    end
  end
end
