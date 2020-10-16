# frozen_string_literal: true

require 'cuprum/collections/errors/invalid_parameters'

require 'stannum/errors'

RSpec.describe Cuprum::Collections::Errors::InvalidParameters do
  subject(:error) { described_class.new(command: command, errors: errors) }

  let(:command) { Cuprum::Command.new }
  let(:errors)  { Stannum::Errors.new }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.collections.errors.invalid_parameters'
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:command, :errors)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'command_class' => command.class.name,
          'errors'        => errors.to_a
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should define reader', :as_json, -> { expected }
  end

  describe '#command' do
    include_examples 'should define reader', :command, -> { command }
  end

  describe '#errors' do
    include_examples 'should define reader', :errors, -> { errors }
  end

  describe '#message' do
    include_examples 'should define reader',
      :message,
      'invalid parameters for command Cuprum::Command'
  end

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end
end
