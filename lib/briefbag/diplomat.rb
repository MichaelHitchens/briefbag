# frozen_string_literal: true

require 'diplomat'
require 'byebug'
require 'socket'

module Briefbag
  class Diplomat
    Result = Struct.new(:success?, :errors, :consul_data)
    attr_reader :config, :consul_folder

    def initialize(config)
      @config = config
      @consul_folder = "#{config[:environment]}/#{config[:consul_folder]}"
    end

    def call
      configuration
      data_from_consul
    end

    def configuration
      ::Diplomat.configure do |conf|
        # Set up a custom Consul URL
        conf.url = url_build(config[:consul_host], config[:consul_port])
        conf.options = {
          ssl: { version: :TLSv1_2 }, # rubocop:disable Naming/VariableNumber
          headers: { 'X-Consul-Token' => config[:consul_token] }
        }
      end
    end

    private

    def consul_data
      ::Diplomat::Kv.get_all(consul_folder)
    end

    def json_parsing(value)
      return JSON.parse(value.force_encoding('UTF-8')) if value.encoding.eql? 'ASCII-8BIT'

      JSON.parse(value)
    end

    def mapping_hash
      consul_data.each_with_object({}) do |item, hash|
        hash[item[:key].split('/').last.to_sym] = json_parsing(item[:value])
      end
    end

    def parsed_configs
      Result.new(true, nil, mapping_hash)
    rescue StandardError => e
      Result.new(false, [e], nil)
    end

    def data_from_consul
      return Result.new(false, 'consul unavailable', nil) unless check_consul.success?
      return Result.new(false, parsed_configs.errors, nil) unless parsed_configs.success?

      parsed_configs
    rescue StandardError => e
      Result.new(false, [e], nil)
    end

    def url_build(host, port)
      Object.const_get("URI::HTTP#{port.eql?(443) ? 'S' : ''}").build(host: host, port: port)
    end

    def check_consul
      Timeout.timeout(1) { TCPSocket.new(config[:consul_host], config[:consul_port]) }
      Result.new(true, nil, nil)
    rescue Timeout::Error => e
      Result.new(false, [e], nil)
    end
  end
end
