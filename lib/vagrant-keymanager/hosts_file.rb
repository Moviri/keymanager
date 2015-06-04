require 'tempfile'
require 'pp'

module VagrantPlugins
	module KeyManager
		module HostsFile
			def get_guest_keys(machine)
				machines = get_machines
				#running_machines = machines.reject {|m| m.state.short_description.to_s != "running"}
				running_machines = machines.select {|m| m.communicate.ready? }

				machines.each do |curr_machine|
					#if curr_machine.state.short_description.to_s != "running"
					if ! curr_machine.communicate.ready?
						puts "Skipping machine "+curr_machine.name.to_s+ ". It's not in running state"
					end
				end

				sshkeys = Hash.new
				required_users = machine.config.keymanager.user_list

				puts "REQUIRED USERS:"
				pp required_users

				running_machines.each do |curr_machine|
					curr_machine.communicate.sudo("rm -f /tmp/add_ssh_keys.sh /tmp/get_user_keys.sh")
					# TODO: save these 2 bash script with curr_machine.communicate.upload
					# We must save locally a bash script that computes and applies diff and always exits with 0 or vagrant plugin will exit with an error
					curr_machine.communicate.execute("echo -e 'diff --changed-group-format=\"%>\" --unchanged-group-format=\"\" ~/.ssh/authorized_keys $1 >>~/.ssh/authorized_keys\nexit 0' >/tmp/add_ssh_keys.sh")
					# We must save locally a bash script that gets ssh keys from any user (will passed as a aparameter)
					curr_machine.communicate.execute("echo -e 'if [ ! -e ~/.ssh/id_rsa ] || [ ! -e ~/.ssh/id_rsa.pub ]; then\n\tssh-keygen -q -f ~/.ssh/id_rsa -P \"\"\nfi\ncat ~/.ssh/id_rsa.pub' >/tmp/get_user_keys.sh")

					curr_machine_name=curr_machine.name.to_s
					puts "Getting SSH keys from "+curr_machine_name

					required_users.each do |curr_user|
						if !check_user_existence(curr_machine, curr_user)
							create_user(curr_machine, curr_user)
						end

						if !sshkeys[curr_user]
							sshkeys[curr_user] = Hash.new
						end
						sshkey=get_user_key(curr_machine, curr_user)
						#puts "SSH key for "+curr_user+": "+sshkey
						sshkeys[curr_user][curr_machine_name] = sshkey
					end
				end

				#pp sshkeys

				running_machines.each do |curr_machine|
					curr_machine_name=curr_machine.name.to_s

					puts "Saving public SSH keys to "+curr_machine_name

					required_users.each do |curr_user|
						curr_machine.communicate.sudo("rm -f /tmp/.all_"+curr_user+"_keys.txt")

						ssh_keys_to_save=sshkeys[curr_user].reject{|k,v| k == curr_machine_name}.values.join.gsub("\n\n", '\n')
						curr_machine.communicate.execute("sudo -u "+curr_user+" -H echo '"+ssh_keys_to_save+"' >/tmp/.all_"+curr_user+"_keys.txt")
						#puts "Saved /tmp/.all_"+curr_user+"_keys.txt"
					end

					required_users.each do |curr_user|
						required_users.each do |source_user|
							curr_machine.communicate.execute("sudo -u "+curr_user+" -H sh /tmp/add_ssh_keys.sh /tmp/.all_"+source_user+"_keys.txt")
						end
						#puts "Saved user "+curr_user+"keys"
					end
				end

				running_machines.each do |curr_machine|
					call_extra_user_steps(curr_machine)
				end

				running_machines.each do |curr_machine|
					curr_machine.communicate.sudo("rm -f /tmp/add_ssh_keys.sh /tmp/get_user_keys.sh")
					required_users.each do |curr_user|
						curr_machine.communicate.sudo("rm -f /tmp/.all_"+curr_user+"_keys.txt")
					end
				end
			end

			private

			def check_user_existence(machine, username)
				if username != "root"
					user_id = ""
					machine.communicate.execute("id -u "+username+" 2>/dev/null; exit 0") do |type, data|
						user_id << data if type == :stdout
					end
					return user_id != ""
				else
					return true
				end
			end

			def create_user(machine, username)
				puts "Creating user "+username+" on "+machine.name.to_s
				machine.communicate.sudo("adduser "+username)
			end

			def get_user_key(machine, username)
				sshresult=""
				machine.communicate.execute("sudo -u "+username+" -H sh /tmp/get_user_keys.sh") do |type, data|
					sshresult << data if type == :stdout
				end
				return sshresult
			end

			def call_extra_user_steps(resolving_machine)
				extra_user_steps = machine.config.keymanager.extra_steps
				if extra_user_steps
					machines = @global_env.machine_names
					machines.map { |machine| extra_user_steps.call(machine, resolving_machine) }
				end
			end

			def get_machines
				machines = @global_env.machine_names
				# Collect only machines that exist for the current provider
				machines.collect do |name|
							begin
								machine = @global_env.machine(name, @provider)
							rescue Vagrant::Errors::MachineNotFound
								# ignore
							end
							machine
						end
					.reject(&:nil?)
			end      

		end
	end
end
