# frozen_string_literal: true

$LOAD_PATH << './lib'

require 'cuprum/collections/version'

Gem::Specification.new do |gem|
  gem.name        = 'cuprum-collections'
  gem.version     = Cuprum::Collections::VERSION
  gem.date        = Time.now.utc.strftime '%Y-%m-%d'
  gem.summary     = 'A data abstraction layer based on the Cuprum library.'
  gem.description = <<~DESCRIPTION.gsub(/\s+/, ' ').strip
    An adapter library to provide a consistent interface between data stores.
  DESCRIPTION
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'

  gem.require_path = 'lib'
  gem.files        = Dir['lib/**/*.rb', 'LICENSE', '*.md']

  gem.add_runtime_dependency 'cuprum', '0.10.0.rc.0'

  gem.add_development_dependency 'byebug'
  gem.add_development_dependency 'rspec', '~> 3.9'
  gem.add_development_dependency 'rspec-sleeping_king_studios', '~> 2.5'
  gem.add_development_dependency 'rubocop', '~> 0.88.0'
  gem.add_development_dependency 'rubocop-rspec', '~> 1.42.0'
  gem.add_development_dependency 'simplecov', '~> 0.18'
end
