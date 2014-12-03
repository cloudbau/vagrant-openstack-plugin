# Changelog for vagrant-openstack-plugin

## 0.11.0

- Merge pull request #97 from cbaenziger/issue_96_fix [view commit](http://github.com///commit/36295904ffb65d7461870a97e561c470fdedbbe5)
- Merge pull request #95 from cbaenziger/volume_support [view commit](http://github.com///commit/3d3fb8d6ae3b3115abea725820ac4a205c814070)
- Retry server deletes until we are sure the VM is dead -- only then remove IP's and volumes [view commit](http://github.com///commit/8799e70521a4ad4c4d1a5aa2a3ea42b83c042c38)
- Update README for more volume related material [view commit](http://github.com///commit/c0e6e0afae67a1e63095f917d50b7c3aa3655547)
- Fix to prevent stack trace failing to find VM, if destroying a non-existant VM [view commit](http://github.com///commit/7632b70a9f2c5af3a6d46a31b2ce4beb1bc9217b)
- Use same check as connect.rb for Vagrantfile disks section [view commit](http://github.com///commit/bd440fbacd7abc7914629431edd74e73cad71f95)
- Fix issue finding volumes if running vagrant destroy after server is destroyed [view commit](http://github.com///commit/8629390d724cdaa611504121bca64690e191cdba)

## 0.10.0

- Merge pull request #84 from cbaenziger/volume_support [view commit](http://github.com///commit/fc613a49cb5b2fecf2255d3050d1bff68956735d)
- Add support for creating OpenStack Volumes [view commit](http://github.com///commit/60ed3924957bb7eefa95e113336165d76da3a985)

## 0.9.1

- Merge pull request #91 from Chealion/master [view commit](http://github.com///commit/6285cae325afa378e90f06635a2cc39b1428a6dd)
- Fixes #90 that hostname is set to key path [view commit](http://github.com///commit/5feb04c7bf46cee1ef4d38e25d74710ea9d0981b)
- Merge pull request #89 from reachlocal/fix_handleurl_deprecation_for_older_versions [view commit](http://github.com///commit/6ba9ee7d18d63a3d6f254c80e106bc440003fae6)
- Added a check for the vagrant version to keep HandleUrl for older versions of vagrant [view commit](http://github.com///commit/07871ed10ea9cca9c51e97fb8bb3e11c33d41a33)

## 0.9.0

- Merge pull request #80 from hawknewton/network_fix [view commit](http://github.com///commit/542e7a2e077d624df9cb56a53c24cf3450e11c71)
- Merge pull request #86 from ipoddar-ibm/master [view commit](http://github.com///commit/11fccb73264aa852df88825936026a9da4771580)
- Merge pull request #88 from chino/fix-rsync-identify-file-options [view commit](http://github.com///commit/9319af5216c8c65ba144154ddfba2c1d767c567d)
- Merge pull request #87 from arbrandes/master [view commit](http://github.com///commit/49839de94e1865eb88a25d5876f1698e2069a0be)
- sync_folders: should have space between ssh-i options [view commit](http://github.com///commit/07325bfe4c782043d7ecec32a64fa516344cebf8)
- Allocate IPs automatically [view commit](http://github.com///commit/84c311544d00286fc2c910f9147892e5ae6c0a5b)
- Adds support for static IPs and interface config [view commit](http://github.com///commit/a5fdb22e23687c9bcd540b37b65b8d478d3a5d94)
- remove extra line [view commit](http://github.com///commit/010e347acf403d6426fffac5ec01cb999dd9545f)
- fix typo [view commit](http://github.com///commit/08dda991121f7e2e2f5bb8f32e03432f69aec226)
- support cygwin [view commit](http://github.com///commit/62c2184906e444c22933d34b8b9054fca56df54f)
- Connect to openstack network resource when needed [view commit](http://github.com///commit/8515a9305f354963d8687077e203a35c902035ce)

## 0.8.0

- Merge pull request #67 from pradels/master [view commit](http://github.com///commit/15f5b5531622376df952bccc0512a6de50d7a92f)
- Merge pull request #66 from matope/use-execute-to-make-synced_folder [view commit](http://github.com///commit/96f64a846d40e5c7f0355def17189e38895e29f3)
- Merge pull request #72 from mathuin/fix-handlebox [view commit](http://github.com///commit/3396e33e54d2527d28a70f1487da6221cd2316e2)
- Merge pull request #64 from bewiwi/reboot [view commit](http://github.com///commit/24bec035508853be871ed8ed73b1d33f15beff76)
- Merge pull request #63 from bewiwi/status [view commit](http://github.com///commit/79a8c341501461a0d5ef1ce4f11cc0a1810d38f3)
- Merge pull request #71 from bewiwi/add_openstack_snapshot_commmand [view commit](http://github.com///commit/bf4eedd6eb5e29aefe4c0e156b932b4f4a81e1f5)
- Merge pull request #73 from detiber/configNetworks [view commit](http://github.com///commit/5e17c5aaeee7bebc4991e440565f2ee4c1b6f191)
- Set config.networks to [] if unset [view commit](http://github.com///commit/5aad087358792bee0bd1a6a026820b04bb8ca68f)
- Changed HandleBoxUrl to HandleBox. [view commit](http://github.com///commit/ad7b2acdea81fe6f4b50e4658ecd36762a849f74)
- Add command snapshot [view commit](http://github.com///commit/2d207ced7e70fe206fa309ed43a8ace3eb86b327)
- Orchestration support added. [view commit](http://github.com///commit/d4e098db8517d491adfeb826500ac3ec5384d237)
- Avoid using sudo to make synced_folder if possible [view commit](http://github.com///commit/b5b6205fbc34e95b4dbd9c13f974b728cb27c76e)
- Add some status messages [view commit](http://github.com///commit/0c9287bc765e074eac104e02d7a64b36bd122034)
- Modify reload action to be a real reboot [view commit](http://github.com///commit/91f5dc65a781d062d156b912bfd9d4b84db82e44)

## 0.7.0

- Merge pull request #35 from johnbellone/master [view commit](http://github.com///commit/5969261f11585e19348e903eec15617634c3c899)
- Fix issues with SSH private keys in Vagrant 1.4. [view commit](http://github.com///commit/a8bf7574de48dc1c62928f5ad73fb6d1e7dd4347)
- Refactor OpenStack actions to match AWS. [view commit](http://github.com///commit/c7177dc98ba43e3434075186a76df57d27ce7b26)

## 0.6.1

- Merge pull request #60 from matope/fix-floating_ip-NoMethodError [view commit](http://github.com///commit/a058256c27573c7545afbc09cce60214731e6e4e)
- Fix NoMethodError on vagrant up w/o floating_ip [view commit](http://github.com///commit/be6fb0d46f69a3b9925c11648e5bc71af4491a7d)

## 0.6.0

- Merge pull request #59 from virtuald/fixed_automatic_ip [view commit](http://github.com///commit/7e7867ee7340515a8d0171fe5ea88aa340646e0f)
- Update README with additional information about automatic allocation [view commit](http://github.com///commit/ea4ee9f409f61a2583588d3782701fe66239bd24)
- Allow address_id to use the automatically assigned floating ip [view commit](http://github.com///commit/cb0e29c20e7105dae2a6534ccaebbe656c0d8419)
- Update README [view commit](http://github.com///commit/b26f70653fb7cfbfe9604031d82aa42d4a324421)
- Add support for automatically allocating a floating IP [view commit](http://github.com///commit/aee3129fc6020d3e3a6cc8db28b9b1c812225fbc)
- update changelog [view commit](http://github.com///commit/936a2eef3d802d65a9f0753b5652ef4a8dbdb345)

## 0.5.0


- Merge pull request #45 from detiber/fixNetworksPR [view commit](http://github.com///commit/56b28eff5a1079c6805ec944b1a0c1dde458b10e)
- Merge pull request #53 from tjheeta/remote_machine_id [view commit](http://github.com///commit/5873d1b5282fe2d24a0e725ec6289d1ba5e20e9b)
- Merge pull request #54 from last-g/patch-1 [view commit](http://github.com///commit/7941573ef8f547a915e31c51ab4d1b85b878eebe)
- Merge pull request #56 from nicobrevin/feature-no-verify-peer [view commit](http://github.com///commit/844835811808d256f67ad43e0124ace3f552a18c)
- Merge pull request #58 from ohnoimdead/no-network-fix [view commit](http://github.com///commit/4b44a7c80d4a381531266844a5c99de0eea850b5)
- Fix for exception when OS endpoint doesn't have neutron installed [view commit](http://github.com///commit/7558bbed3b5ecae8bb3e3ca9c64ffc9512a4c170)
- add ssl_verify_peer config option [view commit](http://github.com///commit/cb94f002d790afb5fbec225d17385c8f5b0ebb35)
- Missing semicolon [view commit](http://github.com///commit/8f609ee474b548b096e42b08c27fc5f874037204)
- Missing region while configuring networks [view commit](http://github.com///commit/ea10bff5cdabea0b9c543a5231500fb7f9fd50ac)
- Fix for delete_server [view commit](http://github.com///commit/d4f812eb99d135f7b7c5d210778e92cd8e5a4561)
- If the .vagrant directory does not contain the machine id, try to connect remotely to try to find it [view commit](http://github.com///commit/71447bf49afe1fed29fa7ce561305dcc756a2e16)
- Fix test for config.network and config.networks. [view commit](http://github.com///commit/5c9161aaf3ac715bc52819ee99c2d02d8434ea7b)

## 0.4.1

- update release info [view commit](http://github.com///commit/9866c83713ec0f1db8aed02a9aa9cbaafe8e85a4)

## 0.4.0

- Merge pull request #49 from RackerJohnMadrid/fix-rsync-vagrant-1-4 [view commit](http://github.com/cloudbau/vagrant-openstack-plugin/commit/5664ead3fda8f889dad72de1de2fbb
- fixes the issue of ssh keys now being represented as an Array in vagrant >= 1.4 [view commit](http://github.com/cloudbau/vagrant-openstack-plugin/commit/0741d802a13c4a858
- fix regression wrt multiple nics [view commit](http://github.com/cloudbau/vagrant-openstack-plugin/commit/9c5441db359b34f2bbf66d30853c97b0896a494b)
- update README [view commit](http://github.com/cloudbau/vagrant-openstack-plugin/commit/725e66ab7970e5698aa7347dae93f791e926097a)
- implement multiple networks [view commit](http://github.com/cloudbau/vagrant-openstack-plugin/commit/0bbbda10bc3b6a09e3165936a2cd17d56b9d3159)
- two minor rsync bugfixes [view commit](http://github.com/cloudbau/vagrant-openstack-plugin/commit/5bf54e8ab99baa850631803137d991a4756f34ab)
- Merge pull request #33 from johnbellone/master [view commit](http://github.com/cloudbau/vagrant-openstack-plugin/commit/f863781405a1070fe991f55f93d2b37763f6c1da)
- Add actions for pausing/suspending (and inverse). [view commit](http://github.com/cloudbau/vagrant-openstack-plugin/commit/a5ec0edd25af250599e0e248a25d8a34af0e1c40)
- Merge pull request #31 from johnbellone/master [view commit](http://github.com/cloudbau/vagrant-openstack-plugin/commit/83031f79e5834693e2c45656c0ae17b6f13afe83)
- Add a little debugging output. [view commit](http://github.com/cloudbau/vagrant-openstack-plugin/commit/c00310ed8855d3b2b0472ab9304debefbb0918e3)
- Add travis.yml file to the project. [view commit](http://github.com/cloudbau/vagrant-openstack-plugin/commit/bc53baaa43c2bf652294d374e071c96bf00bcf12)
- Add proxy option to configuration. [view commit](http://github.com/cloudbau/vagrant-openstack-plugin/commit/3d33bdc9a3bf28af7403bd1a0245a9869799eadc)


## 0.3.0 (September 25, 2013)

- Adds support to determine IP address to use
- Region Support
- Enabled controlling multiple VMs in parallel
- Honor disabling of synced folders
- Adds `availability_zone` option to specify instance zone
- Added --delete to rsync command
- Call SetHostname action from Vagrant core in up phase
- Handled not having the box and providing it via a box_url.
- Allowed vagrant ssh -c 'command'
- Adds tenant to network request
- Improved documentation

## 0.2.2  (May 30, 2013)

- Also ignore HOSTUNREACH errors when first trying to connect to newly created VM

## 0.2.1 (May 29, 2013)

- Fix passing user data to server on create
- Floating IP Capability
- Added ability to configure scheduler hints
- Update doc (network config in fact has higher precedence than address_id)
- 'address_id' now defaults to 'public', to reduce number of cases in read_ssh_info
- Introduced 'address_id' config, which has a higher order of precedence than 'network'

## 0.2.0 (May 2, 2013)

- Added docs
- Removed metadata validation and bumped version
- Tenant and security groups are now configurable

## 0.1.3 (April 26, 2013)

- Added the ability to pass metadata keypairs to instances
- Added support for nics configurations to allow for selection of a specific network on creation

## 0.1.2 (April 26, 2013)

- Added the option of passing user data to VMs
- Enabled `vagrant provision` in this provider
- Made finding IP address more stable
- Doc improvements and minor fixes

## 0.1.0 (March 14, 2013)

- Initial release
