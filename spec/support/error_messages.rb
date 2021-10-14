# frozen_string_literal: true

require 'stannum/messages/default_strategy'

RSpec.configure do |config|
  config.before(:suite) do
    Stannum::Messages::DefaultStrategy.load_paths <<
      File.join(Cuprum::Collections.gem_path, 'config', 'locales')
  end
end
