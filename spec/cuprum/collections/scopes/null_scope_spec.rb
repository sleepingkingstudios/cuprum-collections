# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scope_contracts'
require 'cuprum/collections/scopes/null_scope'

RSpec.describe Cuprum::Collections::Scopes::NullScope do
  include Cuprum::Collections::RSpec::Contracts::ScopeContracts

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end

  include_contract 'should be a null scope', abstract: true
end
