# frozen_string_literal: true

require 'diplomat'
require 'socket'
require 'yaml'

module Briefbag
  class Diplomat
    Result = Struct.new(:success?, :errors, :consul_data)
    attr_reader :config, :consul_folder, :host, :port

    def initialize(config)
      @config = config
      @host = config[:consul_host]
      @port = config[:consul_port].nil? ? 443 : config[:consul_port]
      @consul_folder = "#{config[:environment]}/#{config[:consul_folder]}"
    end

    def call
      configuration
      data_from_consul
    end

    def configuration
      ::Diplomat.configure do |conf|
        conf.url = url_build
        break if config[:consul_token].nil?

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

    def mapping_hash
      consul_data.each_with_object({}) do |item, hash|
        hash[item[:key].split('/').last.to_sym] = ::YAML.safe_load(item[:value])
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

    def url_build
      Object.const_get("URI::HTTP#{port.eql?(443) ? 'S' : ''}").build(host: host, port: port)
    end

    def check_consul
      Timeout.timeout(1) { TCPSocket.new(host, port) }
      Result.new(true, nil, nil)
    rescue Timeout::Error => e
      Result.new(false, [e], nil)
    end
  end
end
