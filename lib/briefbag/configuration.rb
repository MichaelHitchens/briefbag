# frozen_string_literal: true

require 'briefbag/diplomat'
require 'anyway_config'
require 'rainbow'
require 'byebug'
require 'hash_to_struct'

module Briefbag
  class Configuration
    attr_reader :config, :config_name

    MESSAGES = {
      notice_yml: 'NOTICE! Your app using configs from yml file',
      notice_consul: 'NOTICE! Your app using configs from consul now
        If you want to use local configs need to create config file. Just run `rake settings:consul2yml`',
      error_consul: 'ALARM! You try are get consul config, but not connection to consul.
        Please! connect to VPN or check consul configuration',
      error_yml: "ALARM! You try are using local schema connection! But file configuration doesn't exist!
        Just run `rake settings:consul2yml`"
    }.freeze

    def initialize(config)
      @config_name = config[:config_name] || 'application'
      @config = config
    end

    def call
      diplomat = Briefbag::Diplomat.new(config).call

      return file_config if file_exist? && config[:environment].eql?('development')

      return diplomat_config(diplomat[:consul_data]) if diplomat.success?
      return Briefbag.aborting_message(MESSAGES[:error_consul]) unless diplomat.success?
    rescue StandardError
      return Briefbag.aborting_message(MESSAGES[:error_yml]) unless file_exist?

      file_config
    end

    def diplomat_config(data)
      Briefbag.warning_message(MESSAGES[:notice_consul])
      HashToStruct.struct(data)
    end

    def file_config
      Briefbag.warning_message(MESSAGES[:notice_yml])
      data = Anyway::Config.for(:application)[config[:environment]]
      HashToStruct.struct(data)
    end

    def file_exist?
      return true if File.exist?(yaml_file)

      false
    end

    def yaml_file
      @yaml_file ||= "./config/#{config_name}.yml"
    end

    def local_keys
      @local_keys ||= YAML.safe_load(File.read(yaml_file))[environment].keys
    end
  end
end
