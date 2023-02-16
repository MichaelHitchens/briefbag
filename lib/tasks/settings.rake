# frozen_string_literal: true

namespace :settings do
  desc 'create application.yml from consul data'

  # task :consul2yml [:consul_host, :consul_port, :consul_token, :consul_folder, :environment] do |_t, args|
  #   ss = Briefbag::Diplomat.new(consul_host: args[:consul_host],
  #                               consul_port: args[:consul_port],
  #                               consul_token: args[:consul_token],
  #                               consul_folder: args[:consul_folder],
  #                               environment: args[:environment]).call
  #   puts ss
  # end

  task consul2yml: :environment do
    p 'ya rake task'
  end

  desc 'create application.yml from template'
  task template2yml: :environment do
    p 'ya rake task'
  end
end
