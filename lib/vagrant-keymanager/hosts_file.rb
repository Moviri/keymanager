require 'tempfile'

module VagrantPlugins
  module KeyManager
    module HostsFile
      def get_guest_keys(machine)
        if (!machine.communicate.test("test -e ~/.ssh/id_rsa") or !machine.communicate.test("test -e ~/.ssh/id_rsa.pub"))
          machine.communicate.execute("ssh-keygen -q -f ~/.ssh/id_rsa -P ''")
        end
        machine.sshresult=""
        machine.communicate.execute("cat ~/.ssh/id_rsa.pub") do |type, data|
          machine.sshresult << data if type == :stdout
        end
        puts "SSH key: "+machine.sshresult

        if (!machine.communicate.test("sudo test -e ~/.ssh/id_rsa") or !machine.communicate.test("sudo test -e ~/.ssh/id_rsa.pub"))
          machine.communicate.sudo("ssh-keygen -q -f ~/.ssh/id_rsa -P ''")
        end
        machine.sshrootresult = ""
        machine.communicate.sudo("cat ~/.ssh/id_rsa.pub") do |type, data|
          machine.sshrootresult << data if type == :stdout
        end
        puts "SSH root key: "+machine.sshrootresult

        call_custom_solver(machine)
      end

      def set_guest_keys(machine)
        puts "TODO: SET SSH key"
      end

      private

      def call_custom_solver(resolving_machine)
        custom_ssh_resolver = machine.config.keymanager.ssh_resolver
        if custom_ssh_resolver
          get_machines.map { |machine| custom_ssh_resolver.call(machine, resolving_machine) }
        end
      end

      def get_machines
        if @config.hostmanager.include_offline?
          machines = @global_env.machine_names
        else
          machines = @global_env.active_machines
            .select { |name, provider| provider == @provider }
            .collect { |name, provider| name }
        end
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
