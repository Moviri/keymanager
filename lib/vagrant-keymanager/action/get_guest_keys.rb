require 'vagrant-keymanager/hosts_file'

module VagrantPlugins
  module KeyManager
    module Action
      class GetGuestKeys
        include HostsFile

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @global_env = @machine.env
          @provider = env[:provider]

          # config_global is deprecated from v1.5
          if Gem::Version.new(::Vagrant::VERSION) >= Gem::Version.new('1.5')
            @config = @global_env.vagrantfile.config
          else
            @config = @global_env.config_global
          end
          
          @logger = Log4r::Logger.new('vagrant::keymanager::get_guest_keys')
        end

        def call(env)
          env[:ui].info I18n.t('vagrant_keymanager.action.get_guest_keys', {
            :name => @machine.name
          })
          get_guest_keys(@machine)

          @app.call(env)
        end
      end
    end
  end
end
