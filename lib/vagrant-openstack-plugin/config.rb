require "vagrant"

module VagrantPlugins
  module OpenStack
    class Config < Vagrant.plugin("2", :config)
      # The API key to access OpenStack.
      #
      # @return [String]
      attr_accessor :api_key

      # The endpoint to access OpenStack. If nil, it will default
      # to DFW.
      #
      # @return [String]
      attr_accessor :endpoint

      # The flavor of server to launch, either the ID or name. This
      # can also be a regular expression to partially match a name.
      attr_accessor :flavor

      # The name or ID of the image to use. This can also be a regular
      # expression to partially match a name.
      attr_accessor :image

      # The name of the server. This defaults to the name of the machine
      # defined by Vagrant (via `config.vm.define`), but can be overriden
      # here.
      attr_accessor :server_name

      # The username to access OpenStack.
      #
      # @return [String]
      attr_accessor :username
      
      # The name of the keypair to use.
      #
      # @return [String]
      attr_accessor :keypair_name
      
      # Network configurations for the instance
      #
      # @return [String]
      attr_accessor :network

      # List of strings representing the security groups to apply.
      # e.g. ['ssh', 'http']
      #
      # @return [Array[String]]
      attr_accessor :security_groups

      # The SSH username to use with this OpenStack instance. This overrides
      # the `config.ssh.username` variable.
      #
      # @return [String]
      attr_accessor :ssh_username

      # A Hash of metadata that will be sent to the instance for configuration
      #
      # @return [Hash]
      attr_accessor :metadata

      # The tenant to use.
      #
      # @return [String]
      attr_accessor :tenant

      # User data to be sent to the newly created OpenStack instance. Use this
      # e.g. to inject a script at boot time.
      #
      # @return [String]
      attr_accessor :user_data

      def initialize
        @api_key  = UNSET_VALUE
        @endpoint = UNSET_VALUE
        @flavor   = UNSET_VALUE
        @image    = UNSET_VALUE
        @server_name = UNSET_VALUE
        @metatdata = UNSET_VALUE
        @username = UNSET_VALUE
        @keypair_name = UNSET_VALUE
        @network  = UNSET_VALUE
        @security_groups = UNSET_VALUE
        @ssh_username = UNSET_VALUE
        @tenant = UNSET_VALUE
        @user_data = UNSET_VALUE
      end

      def finalize!
        @api_key  = nil if @api_key == UNSET_VALUE
        @endpoint = nil if @endpoint == UNSET_VALUE
        @flavor   = /m1.tiny/ if @flavor == UNSET_VALUE
        @image    = /cirros/ if @image == UNSET_VALUE
        @server_name = nil if @server_name == UNSET_VALUE
        @metadata = nil if @metadata == UNSET_VALUE
        @username = nil if @username == UNSET_VALUE
        @network = nil if @network == UNSET_VALUE

        # Keypair defaults to nil
        @keypair_name = nil if @keypair_name == UNSET_VALUE

        @security_groups = nil if @security_groups == UNSET_VALUE

        # The SSH values by default are nil, and the top-level config
        # `config.ssh` values are used.
        @ssh_username = nil if @ssh_username == UNSET_VALUE

        @tenant = nil if @tenant == UNSET_VALUE
        @user_data = "" if @user_data == UNSET_VALUE
      end

      def validate(machine)
        errors = []

        errors << I18n.t("vagrant_openstack.config.api_key_required") if !@api_key
        errors << I18n.t("vagrant_openstack.config.username_required") if !@username
        
        { "OpenStack Provider" => errors }
      end
    end
  end
end
