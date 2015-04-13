require 'tempfile'
require 'pp'

module VagrantPlugins
  module KeyManager
    module HostsFile
      def get_guest_keys(machine)
        machines = get_machines

        sshkeys = Hash.new
        sshrootkeys = Hash.new        

        #puts "MACHINES"
        #pp machines
        machines.each do |curr_machine|
            #pp curr_machine
            curr_machine_name=curr_machine.name.to_s
            puts "Getting SSH keys from "+curr_machine_name
            sshkey=get_user_key(curr_machine)
            #puts "SSH key: "+sshkey
            sshkeys[curr_machine_name] = sshkey
            sshrootkey=get_root_key(curr_machine)
            #puts "SSH root key: "+sshrootkey
            sshrootkeys[curr_machine_name] = sshrootkey
        end

        machines.each do |curr_machine|
          curr_machine_name=curr_machine.name.to_s
          curr_machine.communicate.sudo("rm -f /tmp/.all_keys.txt /tmp/.all_root_keys.txt /tmp/add_ssh_keys.sh")

          puts "Saving public SSH keys to "+curr_machine_name
          ssh_keys_to_save=sshkeys.reject{|k,v| k == curr_machine_name}.values.join.gsub("\n\n", '\n')
          curr_machine.communicate.execute("echo '"+ssh_keys_to_save+"' >/tmp/.all_keys.txt")
          #puts "Saved /tmp/.all_keys.txt"

          ssh_root_keys_to_save=sshrootkeys.reject{|k,v| k == curr_machine_name}.values.join.gsub("\n\n", '\n')
          curr_machine.communicate.execute("echo '"+ssh_root_keys_to_save+"' >/tmp/.all_root_keys.txt")

          #puts "Saved /tmp/.all_root_keys.txt"

          # We must save locally a bash script that computes and applies diff and always exits with 0 or vagrant plugin will exit with an error
          curr_machine.communicate.execute("echo 'diff --changed-group-format=\"%>\" --unchanged-group-format=\"\" ~/.ssh/authorized_keys $1 >>~/.ssh/authorized_keys;exit 0' >/tmp/add_ssh_keys.sh")

          curr_machine.communicate.execute("sh /tmp/add_ssh_keys.sh /tmp/.all_keys.txt")
          curr_machine.communicate.execute("sh /tmp/add_ssh_keys.sh /tmp/.all_root_keys.txt")
          #puts "Saved user keys"
          
          curr_machine.communicate.sudo("sh /tmp/add_ssh_keys.sh /tmp/.all_keys.txt")
          curr_machine.communicate.sudo("sh /tmp/add_ssh_keys.sh /tmp/.all_root_keys.txt")
          #puts "Saved root keys"
        end

        machines.each do |curr_machine|
          call_extra_user_steps(curr_machine)
        end

        machines.each do |curr_machine|
          curr_machine.communicate.sudo("rm -f /tmp/.all_keys.txt /tmp/.all_root_keys.txt /tmp/add_ssh_keys.sh")
        end
      end

      private

      def get_user_key(machine)
        if (machine.communicate.test("test -e ~/.ssh/id_rsa") or machine.communicate.test("test -e ~/.ssh/id_rsa.pub"))
          machine.communicate.execute("ssh-keygen -q -f ~/.ssh/id_rsa -P ''")
        end
        sshresult=""
        machine.communicate.execute("cat ~/.ssh/id_rsa.pub") do |type, data|
          sshresult << data if type == :stdout
        end
        return sshresult
      end

      def get_root_key(machine)
        if (machine.communicate.test("sudo test -e ~/.ssh/id_rsa") or machine.communicate.test("sudo test -e ~/.ssh/id_rsa.pub"))
          machine.communicate.sudo("ssh-keygen -q -f ~/.ssh/id_rsa -P ''")
        end
        sshrootresult = ""
        machine.communicate.sudo("cat ~/.ssh/id_rsa.pub") do |type, data|
          sshrootresult << data if type == :stdout
        end
        return sshrootresult
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
