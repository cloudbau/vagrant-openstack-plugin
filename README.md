# Vagrant OpenStack Cloud Provider

This is a [Vagrant](http://www.vagrantup.com) 1.1+ plugin that adds a
[OpenStack Cloud](http://www.openstack.org) provider to Vagrant,
allowing Vagrant to control and provision machines within an OpenStack
cloud.

This plugin started as a fork of the Vagrant RackSpace provider.

**Note:** This plugin requires Vagrant 1.1+.

## Features

* Boot OpenStack Cloud instances.
* SSH into the instances.
* Provision the instances with any built-in Vagrant provisioner.
* Minimal synced folder support via `rsync`.

## Usage

Install using standard Vagrant 1.1+ plugin installation methods. After
installing, `vagrant up` and specify the `openstack` provider. An example is
shown below.

```
$ vagrant plugin install vagrant-openstack-plugin
...
$ vagrant up --provider=openstack
...
```

Of course prior to doing this, you'll need to obtain an OpenStack-compatible
box file for Vagrant.

## Quick Start

After installing the plugin (instructions above), the quickest way to get
started is to actually use a dummy OpenStack box and specify all the details
manually within a `config.vm.provider` block. So first, add the dummy
box using any name you want:

```
$ vagrant box add dummy https://github.com/cloudbau/vagrant-openstack-plugin/raw/master/dummy.box
...
```

And then make a Vagrantfile that looks like the following, filling in
your information where necessary.

```
require 'vagrant-openstack-plugin'

Vagrant.configure("2") do |config|
  config.vm.box = "dummy"

  # Make sure the private key from the key pair is provided
  config.ssh.private_key_path = "~/.ssh/id_rsa"

  config.vm.provider :openstack do |os|
    os.username     = "YOUR USERNAME"          # e.g. "#{ENV['OS_USERNAME']}"
    os.api_key      = "YOUR API KEY"           # e.g. "#{ENV['OS_PASSWORD']}"
    os.flavor       = /m1.tiny/                # Regex or String
    os.image        = /Ubuntu/                 # Regex or String
    os.endpoint     = "KEYSTONE AUTH URL"      # e.g. "#{ENV['OS_AUTH_URL']}/tokens"
    os.keypair_name = "YOUR KEYPAIR NAME"      # as stored in Nova
    os.ssh_username = "SSH USERNAME"           # login for the VM

    os.metadata  = {"key" => "value"}                      # optional
    os.user_data = "#cloud-config\nmanage_etc_hosts: True" # optional
    os.network            = "YOUR NETWORK_NAME"            # optional
    os.networks           = [ "internal", "external" ]     # optional, overrides os.network
    os.address_id         = "YOUR ADDRESS ID"              # optional (`network` above has higher precedence)
    os.scheduler_hints    = {
        :cell => 'australia'
    }                                          # optional
    os.availability_zone  = "az0001"           # optional
    os.security_groups    = ['ssh', 'http']    # optional
    os.tenant             = "YOUR TENANT_NAME" # optional
    os.floating_ip        = "33.33.33.33"      # optional (The floating IP to assign for this instance)
  end
end
```

And then run `vagrant up --provider=openstack`.

This will start a tiny Ubuntu instance in your OpenStack installation within
your tenant. And assuming your SSH information was filled in properly
within your Vagrantfile, SSH and provisioning will work as well.

Note that normally a lot of this boilerplate is encoded within the box
file, but the box file used for the quick start, the "dummy" box, has
no preconfigured defaults.

## Box Format

Every provider in Vagrant must introduce a custom box format. This
provider introduces `openstack` boxes. You can view an example box in
the [example_box/ directory](https://github.com/cloudbau/vagrant-openstack-plugin/tree/master/example_box).
That directory also contains instructions on how to build a box.

The box format is basically just the required `metadata.json` file
along with a `Vagrantfile` that does default settings for the
provider-specific configuration for this provider.

## Configuration

This provider exposes quite a few provider-specific configuration options:

* `api_key` - The API key for accessing OpenStack.
* `flavor` - The server flavor to boot. This can be a string matching
  the exact ID or name of the server, or this can be a regular expression
  to partially match some server flavor.
* `image` - The server image to boot. This can be a string matching the
  exact ID or name of the image, or this can be a regular expression to
  partially match some image.
* `endpoint` - The keystone authentication URL of your OpenStack installation.
* `server_name` - The name of the server within the OpenStack Cloud. This
  defaults to the name of the Vagrant machine (via `config.vm.define`), but
  can be overridden with this.
* `username` - The username with which to access OpenStack.
* `keypair_name` - The name of the keypair to access the machine.
* `ssh_username` - The username to access the machine. This can also be
  configured using the standard config.ssh.username configuration value.
* `metadata` - A set of key pair values that will be passed to the instance
  for configuration.
* `network` - A name or id that will be used to fetch network configuration
  data when configuring the instance. NOTE: This is not compliant with the
  vagrant network configurations.
* `networks` - An array of names or ids to create a server with multiple network interfaces. This overrides the `network` setting.
* `address_id` - A specific address identifier to use when connecting to the
  instance. `network` has higher precedence. If set to :floating_ip, then 
  the floating IP address will be used. 
* `scheduler_hints` - Pass hints to the open stack scheduler, see `--hint` flag in [OpenStack filters doc](http://docs.openstack.org/trunk/openstack-compute/admin/content/scheduler-filters.html)
* `availability_zone` - Specify the availability zone in which the instance
  must be created.
* `security_groups` - List of security groups to be applied to the machine.
* `tenant` - Tenant name.  You only need to specify this if your OpenStack user has access to multiple tenants.
* `region` - Region Name. Specify the region you want the instance to be launched in for multi-region environments.
* `proxy` - HTTP proxy. When behind a firewall override this value for API access.
* `ssl_verify_peer` - sets the ssl_verify_peer on the underlying excon connection - useful for self signed certs etc.
* `floating_ip` - Floating ip. The floating IP to assign for this instance. If
  set to :auto, then this assigns any available floating IP to the instance.

These can be set like typical provider-specific configuration:

```ruby
Vagrant.configure("2") do |config|
  # ... other stuff

  config.vm.provider :openstack do |rs|
    rs.username = "mitchellh"
    rs.api_key  = "foobarbaz"
  end
end
```

## Networks

Networking features in the form of `config.vm.network` are not
supported with `vagrant-openstack-plugin`, currently. If any of these are
specified, Vagrant will emit a warning, but will otherwise boot
the OpenStack server.

## Synced Folders

There is minimal support for synced folders. Upon `vagrant up`,
`vagrant reload`, and `vagrant provision`, the OpenStack provider will use
`rsync` (if available) to uni-directionally sync the folder to
the remote machine over SSH.

This is good enough for all built-in Vagrant provisioners (shell,
chef, and puppet) to work!

## Command

### Snapshot
`vagrant openstack snapshot <vmname> -n <snapshotname>`

Take snapshot of ***vmname*** with name ***snapshotname***

## Contributors

- [mitchellh](https://github.com/mitchellh)
- [tkadauke](https://github.com/tkadauke)
- [srenatus](https://github.com/srenatus)
- [hvolkmer](https://github.com/hvolkmer)
- [ehaselwanter](https://github.com/ehaselwanter)
- [BRIMIL01](https://github.com/BRIMIL01)
- [jkburges](https://github.com/jkburges)
- [johnbellone](https://github.com/johnbellone)
- [mat128](https://github.com/mat128)
- [jtopjian](https://github.com/jtopjian)
- [antoviaque](https://github.com/antoviaque)
- [last-g](https://github.com/last-g)
- [spil-jasper](https://github.com/spil-jasper)
- [detiber](https://github.com/detiber)
- [RackerJohnMadrid](https://github.com/RackerJohnMadrid)
- [Lull3rSkat3r](https://github.com/Lull3rSkat3r)
- [nicobrevin](https://github.com/nicobrevin)
- [ohnoimdead](https://github.com/ohnoimdead)

## Development

To work on the `vagrant-openstack-plugin` plugin, clone this repository out, and use
[Bundler](http://gembundler.com) to get the dependencies:

```
$ bundle
```

Once you have the dependencies, verify the unit tests pass with `rake`:

```
$ bundle exec rake
```

If those pass, you're ready to start developing the plugin. You can test
the plugin without installing it into your Vagrant environment by just
creating a `Vagrantfile` in the top level of this directory (it is gitignored)
that uses it, and uses bundler to execute Vagrant:

```
$ bundle exec vagrant up --provider=openstack
```
