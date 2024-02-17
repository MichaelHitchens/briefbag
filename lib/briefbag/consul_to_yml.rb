module Briefbag
  class ConsulToYml < Briefbag::Runner
    def run
      load_config!
      output = diplomat_config.call

      return warn Rainbow('Consul is down').red unless output.success?

      yml_file = "#{app_root}/#{config_path}"

      if @env == 'development' && !File.exist?(yml_file)
        configs = { "#{config[:environment]}" => output.consul_data }
        warn Rainbow("Start to create #{config_path}").green
        File.write(yml_file, configs.to_yaml)
        warn Rainbow("Done! File #{config_path} has been created!").green
      else
        warn Rainbow("Skip! File #{config_path} exists.").red
      end
    end

    private

    attr_reader :config

    def app_root
      Pathname.new(@app_path)
    end

    def config_path
      @config[:config_path]
    rescue NoMethodError
      warn Rainbow("Consul configuration couldn't be serialized.").red
      $stdout.puts @config.inspect
      exit!
    end

    def load_config!
      return @config if defined? @config

      config_file = app_root.join('config/consul.yml')
      consul_config = YAML.load_file(config_file)[@env].merge!(environment: @env)
      @config ||= symbolize_keys(consul_config)

    rescue Errno::ENOENT, NoMethodError
      warn Rainbow("Consul configuration not found in #{config_path}[#{@env}].").red
      warn Rainbow("Please run `rails briefbag:install`").red
      exit!
    end

    def diplomat_config
      diplomat_config ||= Briefbag::Diplomat.new(config)
    end
  end
end
