# frozen_string_literal: true

require 'briefbag/diplomat'
require 'anyway_config'
require 'rainbow'
require 'hash_to_struct'

module Briefbag
  class Configuration
    attr_reader :config, :config_name

    MESSAGES = {
      notice_yml: 'NOTICE! Your app is using configs from yml file',
      notice_consul: 'NOTICE! Your app is using configs from consul now
        If you want to use local configs. you need to create config file. Just run `rake settings:consul2yml`',
      error_consul: 'ALARM! You are trying to get consul config, but you have no consul connection.
        Please! connect to VPN or check consul configuration',
      error_yml: "ALARM! You are trying to use local schema connection! But file configuration doesn't exist!
        Just run `rake settings:consul2yml`"
    }.freeze

    def initialize(config)
      @config_name = config[:config_name] || 'application'
      @config = config
    end

    def call
      return file_config if file_exist?

      diplomat = Briefbag::Diplomat.new(config).call
      return Briefbag.aborting_message(MESSAGES[:error_consul]) unless diplomat.success?

      diplomat_config(diplomat[:consul_data])
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
      data = Anyway::Config.for(config_name.to_sym)

      return HashToStruct.struct(data.deep_symbolize_keys) if defined?(Rails)

      HashToStruct.struct(symbolize_all_keys(data))[config[:environment]]
    end

    def file_exist?
      @file_exist ||= File.exist?(yaml_file)
    end

    def yaml_file
      @yaml_file ||= "./config/#{config_name}.yml"
    end


    def symbolize_all_keys(h) # rubocop:disable  Naming/MethodParameterName
      if h.is_a? Hash
        h.transform_keys!(&:to_sym)
        h.each_value do |val|
          val.each { |v| symbolize_all_keys(v) } if val.is_a? Array
          symbolize_all_keys(val)
        end
      end
      h
    end
  end
end
