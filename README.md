Vagrant Key Manager
====================
`vagrant-keymanager` is a Vagrant 1.1+ plugin that manages SSH keys
on guest machines. Its goal is to enable resolution of multi-machine
environments deployed with a cloud provider where SSH keys are not
known in advance when providing.

Installation
------------
Install the plugin following the typical Vagrant 1.1 procedure:

    $ vagrant plugin install vagrant-keymanager

Usage
-----

THIS A STILL A WORK IN PROGRESS. DO NOT USE

Example configuration:

```ruby
Vagrant.configure("2") do |config|
  config.vm.define 'example-box' do |node|
    node.vm.hostname = 'example-box-hostname'
  end
end
```

As a last option, you can use keymanager as a provisioner.
This allows you to use the provisioning order to ensure that keymanager
runs before or after provisioning. The provisioner will collect hosts from
boxes with the same provider as the running box.

Use:

```ruby
config.vm.provision :keymanager
```

