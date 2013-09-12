require "vagrant"

module VagrantPlugins
  module OpenStack
    module Errors
      class VagrantOpenStackError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_openstack.errors")
      end

      class CreateBadState < VagrantOpenStackError
        error_key(:create_bad_state)
      end

      class NoMatchingFlavor < VagrantOpenStackError
        error_key(:no_matching_flavor)
      end

      class NoMatchingImage < VagrantOpenStackError
        error_key(:no_matching_image)
      end

      class RsyncError < VagrantOpenStackError
        error_key(:rsync_error)
      end

      class SSHNoValidHost < VagrantOpenStackError
        error_key(:ssh_no_valid_host)
      end

      class FloatingIPNotValid < VagrantOpenStackError
        error_key(:floating_ip_not_valid)
      end
    end
  end
end
