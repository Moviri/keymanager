module VagrantPlugins
  module KeyManager
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :extra_steps
      attr_accessor :user_list

      def initialize
        @extra_steps = nil
        @user_list = UNSET_VALUE
      end

      def finalize!
        @user_list = [] if @user_list == UNSET_VALUE
        @user_list = [ "root", @user_list ].flatten.uniq
      end

      def validate(machine)
        errors = []
        # errors << validate_bool('keymanager.enabled', @enabled)
        errors.compact!

        if !machine.config.keymanager.extra_steps.nil? &&
           !machine.config.keymanager.extra_steps.kind_of?(Proc)
          errors << I18n.t('vagrant_keymanager.config.not_a_proc', {
            :config_key => 'keymanager.extra_steps',
            :is_class   => extra_steps.class.to_s,
          })
        end

        if  !machine.config.keymanager.user_list.kind_of?(Array) &&
            !machine.config.keymanager.user_list.kind_of?(String)
          errors << I18n.t('vagrant_keymanager.config.not_an_array_or_string', {
            :config_key => 'keymanager.user_list',
            :is_class   => user_list.class.to_s,
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
