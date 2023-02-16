# frozen_string_literal: true

module Briefbag
  class Railtie < Rails::Railtie
    railtie_name :briefbag
    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/lib/tasks/**/*.rake").each { |f| load f }
    end
  end
end
