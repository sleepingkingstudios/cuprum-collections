# frozen_string_literal: true

require 'cuprum/collections/basic/scopes/criteria_scope'
require 'cuprum/collections/rspec/contracts/scope_contracts'

RSpec.describe Cuprum::Collections::Basic::Scopes::CriteriaScope do
  include Cuprum::Collections::RSpec::Contracts::ScopeContracts

  subject(:scope) { described_class.new(criteria: criteria) }

  let(:criteria) { [] }

  include_contract 'should be a criteria scope'

  describe '#call' do
    let(:data) { [] }

    def filtered_data
      scope.call(data: data)
    end

    it 'should define the method' do
      expect(scope).to respond_to(:call).with(0).arguments.and_keywords(:data)
    end

    describe 'with nil' do
      let(:error_message) { 'data must be an Array' }

      it 'should raise an exception' do
        expect { scope.call(data: nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:error_message) { 'data must be an Array' }

      it 'should raise an exception' do
        expect { scope.call(data: Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end

    include_contract 'should filter data by criteria'
  end
end
