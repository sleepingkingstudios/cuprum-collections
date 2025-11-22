# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/scopes/all_examples'
require 'cuprum/collections/scopes/all_scope'

RSpec.describe Cuprum::Collections::Scopes::AllScope do
  include Cuprum::Collections::RSpec::Deferred::Scopes::AllExamples

  describe '.instance' do
    let(:expected) { described_class.instance }

    include_examples 'should define class reader', :instance

    it { expect(described_class.instance).to be_a described_class }

    it { expect(described_class.instance).to be expected }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end

  include_deferred 'should implement the AllScope methods', abstract: true
end
