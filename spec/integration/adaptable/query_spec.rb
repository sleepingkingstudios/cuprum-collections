# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/query_examples'
require 'cuprum/collections/rspec/fixtures'

require 'support/adaptable/query'
require 'support/examples/adaptable/command_examples'

RSpec.describe Spec::Support::Adaptable::Query do
  include Cuprum::Collections::RSpec::Deferred::QueryExamples
  include Spec::Support::Examples::Adaptable::CommandExamples

  subject(:query) do
    described_class.new(stringify_data(data), adapter:, scope: initial_scope)
  end

  let(:initial_scope) { nil }

  define_method :add_item_to_collection do |item|
    tools = SleepingKingStudios::Tools::HashTools.instance

    query.send(:data) << tools.convert_keys_to_strings(item)
  end

  include_deferred 'with parameters for an adaptable collection'

  include_deferred 'should be a Query'

  describe '#scope' do
    it 'should define the default scope' do
      expect(query.scope).to be_a Cuprum::Collections::Basic::Scopes::AllScope
    end

    wrap_context 'when initialized with a scope' do
      it 'should transform the scope' do
        expect(query.scope)
          .to be_a Cuprum::Collections::Basic::Scopes::CriteriaScope
      end
    end
  end
end
