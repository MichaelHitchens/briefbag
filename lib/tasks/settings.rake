# frozen_string_literal: true

require 'briefbag'
require 'byebug'
require 'rails'

namespace :settings do
  desc 'create application.yml from consul data'
  task :consul2yml,
       [:consul_host, :consul_port, :consul_token, :consul_folder, :environment, :config_path] do |_t, args|
    diplomat_config = Briefbag::Diplomat.new(
      consul_host: args[:consul_host],
      consul_port: args[:consul_port].to_i,
      consul_token: args[:consul_token],
      consul_folder: args[:consul_folder],
      environment: args[:environment]
    )

    data = diplomat_config.call

    return warn Rainbow('Consul is down').red unless data.success?

    yml_file = "#{Rails.root}/#{args[:config_path]}"
    if Rails.env.development? && !File.exist?(yml_file)
      configs = { "#{args[:environment]}": data.consul_data.deep_symbolize_keys }
      warn Rainbow("Create #{args[:config_path]}").green
      File.write(yml_file, configs.deep_stringify_keys.to_yaml)
      warn Rainbow("Done! File #{args[:config_path]} created!").green
    else
      warn Rainbow("Skip! File #{args[:config_path]} exists.").red
    end
  end

  desc 'Transfer configs file in consul from/to projects'
  task :transfer_config, [:consul_url, :consul_token, :project, :from_env, :to_env] do |_t, args|
    project = args[:project]
    from = args[:from_env]
    to = args[:to_env]

    Diplomat.configure do |config|
      config.url = args[:consul_url]
      config.options = {
        ssl: { version: :TLSv1_2 },
        headers: {
          'X-Consul-Token' => args[:consul_token]
        }
      }
    end
    keys = Diplomat::Kv.get("#{from}/#{project}", keys: true)
    keys.delete_at(0) # delete self name folder
    config_names = keys.map { |k| k.split('/').last }

    config_names.each do |config_name|
      warn Rainbow("Start read data for key: #{config_name}").yellow
      config = Diplomat::Kv.get("#{from}/#{project}/#{config_name}")
      Diplomat::Kv.put("#{to}/#{project}/#{config_name}", config)
      warn Rainbow("Success transfer data for key: #{config_name}").green
    end
  end


  desc 'create application.yml from template'
  task template2yml: :environment do
    p 'ya rake task'
  end
end
