require 'pathname'

module Briefbag
  class Runner
    def self.run(argv)
      $stdout.sync = true

      new(argv).run
    end

    def initialize(argv)
      @argv = argv

      @app_path = File.expand_path(".", Dir.pwd)
      @env = ENV["RAILS_ENV"]
    end

    private

    def symbolize_keys(hash)
      JSON.parse(hash.to_json, symbolize_names: true)
    end
  end
end
