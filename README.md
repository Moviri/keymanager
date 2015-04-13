Vagrant Key Manager
====================
`vagrant-keymanager` is a Vagrant 1.1+ plugin that sets SSH keys
on linux guest machines. It creates public+private keys on every
machine listed in your Vegrantfile and spreads the public keys
across all these machines. All machines should be already up and 
running before provisioning or an error will occur.
Do not use with Windows guest machines.

Installation
------------
Install the plugin following the typical Vagrant 1.1 procedure:

    $ vagrant plugin install vagrant-keymanager

Usage
-----

You can use keymanager as a provisioner.

Use:

```ruby
config.vm.provision :keymanager
```

Let's assume you have three machines defined in you vagrant file.
This pluging will:
* connect to machine A
* generate private and public key for machine A (standard user and root user)
* grab public keys (standard and root) for machine A ad copy them to machine B and C
* Reperat the 3 steps above for machines B and C

There may be cases in which you want to perform some extra steps.
If that's the case you can code extra operations and pass with the optional parameter
extra_steps. Here's a basic example that counts all rsa ssh keys from your machines.
Just put the variable definition before the call to keymanager provisioner.

```ruby
node_config.vm.provider 'aws' do |aws, override|
	aws.access_key_id = AWS_ACCESS_KEY
	aws.secret_access_key = AWS_SECRET_KEY
	aws.keypair_name = AWS_KPAIR_NAME

	override.ssh.username = 'centos'

	override.keymanager.extra_steps = proc do |curr_machine|
	    result = ""
	    curr_machine.communicate.execute("grep '^ssh-rsa' ~/.ssh/authorized_keys | wc -l") do |type, data|
	      result << data if type == :stdout
	      puts "Current machine has "+result+" SSH keys"
	    end
	end
end
```




