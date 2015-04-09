module VagrantPlugins
  module KeyManager
    class Command < Vagrant.plugin('2', :command)
      include HostsFile

      def execute
        options = {}
        opts = OptionParser.new do |o|
          o.banner = 'Usage: vagrant keymanager [vm-name]'
          o.separator ''
          o.version = VagrantPlugins::KeyManager::VERSION
          o.program_name = 'vagrant keymanager'

          o.on('--provider provider', String,
            'Update machines with the specific provider.') do |provider|
            options[:provider] = provider.to_sym
          end
        end

        argv = parse_options(opts)
        options[:provider] ||= @env.default_provider

        # run keymanager for specified guest machines
        with_target_vms(argv, options) do |machine|
          @env.action_runner.run(Action.get_guest_keys, {
            :machine => machine,
            :provider => options[:provider]
          })
        end
      end
    end
  end
end
