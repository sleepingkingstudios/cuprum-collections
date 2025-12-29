# frozen_string_literal: true

require_relative 'lib/cuprum/collections/version'

Gem::Specification.new do |gem|
  gem.name        = 'cuprum-collections'
  gem.version     = Cuprum::Collections::VERSION
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']

  gem.summary     = 'A data abstraction layer based on the Cuprum library.'
  gem.description = <<~DESCRIPTION.gsub(/\s+/, ' ').strip
    An adapter library to provide a consistent interface between data stores.
  DESCRIPTION
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'
  gem.metadata    = {
    'bug_tracker_uri'       => 'https://github.com/sleepingkingstudios/cuprum-collections/issues',
    'homepage_uri'          => gem.homepage,
    'source_code_uri'       => 'https://github.com/sleepingkingstudios/cuprum-collections',
    'rubygems_mfa_required' => 'true'
  }
  gem.required_ruby_version = ['>= 3.2', '< 5']

  gem.require_path = 'lib'
  gem.files = Dir[
    'config/locales/*',
    'lib/**/*.rb',
    'LICENSE',
    '*.md'
  ]

  gem.add_dependency 'cuprum', '~> 1.3', '>= 1.3.1'
  gem.add_dependency 'sleeping_king_studios-tools', '~> 1.2', '>= 1.2.1'
  gem.add_dependency 'stannum', '~> 0.4', '>= 0.4.1'
end
