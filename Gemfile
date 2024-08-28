# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'cuprum',
  '>= 1.3.0.alpha',
  git:    'https://github.com/sleepingkingstudios/cuprum.git',
  branch: 'main'
gem 'sleeping_king_studios-tools',
  '>= 1.2.0.alpha',
  git:    'https://github.com/sleepingkingstudios/sleeping_king_studios-tools.git',
  branch: 'main'
gem 'stannum',
  '>= 0.4.0.alpha',
  git:    'https://github.com/sleepingkingstudios/stannum.git',
  branch: 'main'

group :development do
  gem 'sleeping_king_studios-tasks', '~> 0.4', '>= 0.4.1'

  gem 'yard', '~> 0.9', require: false, group: :doc
end

group :development, :test do
  gem 'byebug', '~> 11.0'

  gem 'rspec', '~> 3.13'
  gem 'rspec-sleeping_king_studios',
    '>= 2.8.0.alpha',
    git:    'https://github.com/sleepingkingstudios/rspec-sleeping_king_studios.git',
    branch: 'main'

  gem 'rubocop', '~> 1.65'
  gem 'rubocop-rspec', '~> 3.0'

  gem 'simplecov', '~> 0.22'
end
