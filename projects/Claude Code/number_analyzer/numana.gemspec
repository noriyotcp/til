# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'numana'
  spec.version       = '1.0.0'
  spec.authors       = ['Claude Code User']
  spec.email         = ['user@example.com']

  spec.summary       = 'A comprehensive statistical analysis tool for number arrays'
  spec.description   = 'Numana provides statistical calculations including sum, average, median, mode, ' \
                       'standard deviation, and more for arrays of numbers.'
  spec.homepage      = 'https://github.com/user/numana'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Runtime dependencies
  spec.add_dependency 'csv', '~> 3.0'
  spec.add_dependency 'json', '~> 2.0'
  spec.add_dependency 'logger', '~> 1.5'

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir['lib/**/*.rb'] + Dir['bin/*'] + ['numana.gemspec', 'Gemfile', 'CLAUDE.md']
  spec.bindir = 'bin'
  spec.executables = ['numana']
  spec.require_paths = ['lib']
end
