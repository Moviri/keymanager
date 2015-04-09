module VagrantPlugins
  module KeyManager
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :aliases
      attr_accessor :ssh_resolver

      def initialize
        @aliases = []
        @aliases = Array.new
        @ssh_resolver = nil
      end

      def finalize!
        @aliases = [ @aliases ].flatten
      end

      def validate(machine)
        errors = []
        # errors << validate_bool('keymanager.enabled', @enabled)
        errors.compact!

        # check if aliases option is an Array
        if  !machine.config.keymanager.aliases.kind_of?(Array) &&
            !machine.config.keymanager.aliases.kind_of?(String)
          errors << I18n.t('vagrant_keymanager.config.not_an_array_or_string', {
            :config_key => 'keymanager.aliases',
            :is_class   => aliases.class.to_s,
          })
        end

        if !machine.config.keymanager.ssh_resolver.nil? &&
           !machine.config.keymanager.ssh_resolver.kind_of?(Proc)
          errors << I18n.t('vagrant_keymanager.config.not_a_proc', {
            :config_key => 'keymanager.ssh_resolver',
            :is_class   => ssh_resolver.class.to_s,
          })
        end

        errors.compact!
        { "KeyManager configuration" => errors }
      end

      private

      def validate_bool(key, value)
        if ![TrueClass, FalseClass].include?(value.class) &&
           value != UNSET_VALUE
          I18n.t('vagrant_keymanager.config.not_a_bool', {
            :config_key => key,
            :value      => value.class.to_s
          })
        else
          nil
        end
      end
    end
  end
end
