# frozen_string_literal: true

require 'stannum/messages/default_strategy'

require 'bronze'

RSpec.configure do |config|
  config.before(:suite) do
    Stannum::Messages::DefaultStrategy.load_paths <<
      File.join(Bronze.gem_path, 'config', 'locales')
  end
end
