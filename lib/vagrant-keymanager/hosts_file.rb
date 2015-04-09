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
      end

      def set_guest_keys(machine)
        puts "TODO: SET SSH key"
      end

      # private

    end
  end
end
