# frozen_string_literal: true

require 'briefbag/version'
require 'briefbag/configuration'

module Briefbag
  class << self
    def warning_message(message, color: nil)
      color ||= :yellow
      warn Rainbow(message).send(:color, color)
    end

    def aborting_message(message)
      abort Rainbow(message).red
    end
  end
  class Error < StandardError; end
end
