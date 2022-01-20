# frozen_string_literal: true

$LOAD_PATH << './lib'

require 'cuprum/collections/version'

Gem::Specification.new do |gem|
  gem.name        = 'cuprum-collections'
  gem.version     = Cuprum::Collections::VERSION
  gem.summary     = 'A data abstraction layer based on the Cuprum library.'
  gem.description = <<~DESCRIPTION.gsub(/\s+/, ' ').strip
    An adapter library to provide a consistent interface between data stores.
  DESCRIPTION
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'

  gem.metadata = {
    'bug_tracker_uri'       => 'https://github.com/sleepingkingstudios/cuprum-collections/issues',
    'source_code_uri'       => 'https://github.com/sleepingkingstudios/cuprum-collections',
    'rubygems_mfa_required' => 'true'
  }

  gem.require_path = 'lib'
  gem.files        = Dir['lib/**/*.rb', 'LICENSE', '*.md']

  gem.required_ruby_version = '>= 2.6.0'

  gem.add_runtime_dependency 'cuprum', '>= 0.11', '< 2.0'
  gem.add_runtime_dependency 'stannum', '~> 0.2'

  gem.add_development_dependency 'rspec', '~> 3.9'
  gem.add_development_dependency 'rspec-sleeping_king_studios', '~> 2.7'
  gem.add_development_dependency 'rubocop', '~> 1.24'
  gem.add_development_dependency 'rubocop-rspec', '~> 2.7'
  gem.add_development_dependency 'simplecov', '~> 0.18'
end
