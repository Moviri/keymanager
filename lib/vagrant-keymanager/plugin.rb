require 'vagrant-keymanager/action'

module VagrantPlugins
  module KeyManager
    class Plugin < Vagrant.plugin('2')
      name 'KeyManager'
      description <<-DESC
        This plugin gets/sets SSH keys from/to guest machine.

        You can also use the keymanager provisioner.
      DESC

      config(:keymanager) do
        require_relative 'config'
        Config
      end

      action_hook(:keymanager, :machine_action_up) do |hook|
        hook.prepend(Action.update_all)
      end

      action_hook(:keymanager, :machine_action_destroy) do |hook|
        hook.prepend(Action.update_all)
      end

      provisioner(:keymanager) do
        require_relative 'provisioner'
        Provisioner
      end

      # Work-around for vagrant >= 1.5
      # It breaks without a provisioner config, so we provide a dummy one
      config(:keymanager, :provisioner) do
        ::Vagrant::Config::V2::DummyConfig.new
      end

      command(:keymanager) do
        require_relative 'command'
        Command
      end
    end
  end
end
