# frozen_string_literal: true

require 'cuprum/collections/scopes/base'
require 'cuprum/collections/rspec/contracts/scopes/composition_contracts'

RSpec.describe Cuprum::Collections::Scopes::Base do
  include Cuprum::Collections::RSpec::Contracts::Scopes::CompositionContracts

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end

  include_contract 'should compose scopes'

  describe '#builder' do
    let(:expected) { Cuprum::Collections::Scopes::Builder.instance }

    include_examples 'should define private reader', :builder, -> { expected }
  end

  describe '#empty?' do
    include_examples 'should define predicate', :empty?, false
  end

  describe '#type' do
    include_examples 'should define reader', :type, :abstract
  end
end
