require 'vagrant-keymanager/action/get_guest_keys'

module VagrantPlugins
  module KeyManager
    module Action
      include Vagrant::Action::Builtin

      def self.get_guest_keys
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use GeyGuestKeys
        end
      end
    end
  end
end
