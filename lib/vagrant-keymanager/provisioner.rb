module VagrantPlugins
  module KeyManager
    class Provisioner < Vagrant.plugin('2', :provisioner)
      include HostsFile

      def initialize(machine, config)
        super(machine, config)
        @global_env = machine.env
        @provider = machine.provider_name

        # config_global is deprecated from v1.5
        if Gem::Version.new(::Vagrant::VERSION) >= Gem::Version.new('1.5')
          @config = @global_env.vagrantfile.config
        else
          @config = @global_env.config_global
        end

      end

      def provision
        get_guest_keys(@machine)
      end
    end
  end
end
