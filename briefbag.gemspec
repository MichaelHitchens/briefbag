# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'briefbag/version'

Gem::Specification.new do |spec|
  spec.name          = 'briefbag'
  spec.version       = Briefbag::VERSION
  spec.authors       = ['Michael Hitchens']
  spec.email         = ['mmseleznev@gmail.com']

  spec.summary = 'Briefbag manage your config'
  spec.homepage = 'https://github.com/MichaelHitchens/briefbag'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.4.2'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage,
    'changelog_uri' => 'https://github.com/MichaelHitchens/briefbag/blob/master/CHANGELOG.md'
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Requires Ruby faraday to http request
  spec.add_dependency 'anyway_config', '~> 1.4.4'
  spec.add_dependency 'diplomat', '~> 2.4.4'
  spec.add_dependency 'hash_to_struct', '~> 1.0.0'
  spec.add_dependency 'rainbow', '~> 3.1.1'

  spec.add_development_dependency 'bundler', '~> 1.17.3'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'faker', '~> 2.12.0'
  spec.add_development_dependency 'rake', '~> 13.0.6'
  spec.add_development_dependency 'rspec', '~> 3.12.0'
  spec.add_development_dependency 'rubocop', '~> 1.12.1'
end
