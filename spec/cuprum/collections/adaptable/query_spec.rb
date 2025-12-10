# frozen_string_literal: true

require 'cuprum/collections/adaptable/query'
require 'cuprum/collections/rspec/deferred/query_examples'

RSpec.describe Cuprum::Collections::Adaptable::Query do
  include Cuprum::Collections::RSpec::Deferred::QueryExamples

  subject(:query) { described_class.new(adapter:, scope: initial_scope) }

  let(:described_class) { Spec::ExampleQuery }
  let(:adapter)         { Cuprum::Collections::Adapter.new }
  let(:initial_scope)   { nil }

  example_class 'Spec::ExampleQuery', Cuprum::Collections::Query do |klass|
    klass.include Cuprum::Collections::Adaptable::Query # rubocop:disable RSpec/DescribedClass
  end

  describe '::AbstractQueryError' do
    it { expect(described_class::AbstractQueryError).to be_a(Class) }

    it { expect(described_class::AbstractQueryError).to be < StandardError }
  end

  describe '::InvalidDataError' do
    it { expect(described_class::InvalidDataError).to be_a(Class) }

    it { expect(described_class::InvalidDataError).to be < StandardError }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:adapter, :scope)
    end
  end

  include_deferred 'should be a Query', abstract: true

  describe '#adapter' do
    it { expect(query.adapter).to be == adapter }
  end

  describe '#convert' do
    let(:error_message) do
      "#{described_class.name} is an abstract class - define a subclass and " \
        'implement the #convert_native_to_attributes method'
    end

    it { expect(query).to respond_to(:convert).with(1).argument }

    it 'should raise an exception' do
      expect { query.convert(Object.new.freeze) }
        .to raise_error(described_class::AbstractQueryError, error_message)
    end

    context 'when the query defines #convert_native_to_attributes' do
      let(:attributes) do
        {
          'id'     => 13,
          'title'  => 'Gideon the Ninth',
          'author' => 'Tamsyn Muir',
          'series' => 'The Locked Tomb'
        }
      end
      let(:adapter) do
        Cuprum::Collections::Adapters::EntityAdapter
          .new(entity_class: Spec::BookEntity)
      end
      let(:native) do
        Spec::BookData.new(**attributes)
      end

      before(:example) do
        described_class.define_method(:convert_native_to_attributes) do |value|
          value.to_h
        end
      end

      example_constant 'Spec::BookData' do
        Data.define(:id, :title, :author, :series) do
          def initialize(**attributes)
            attributes =
              SleepingKingStudios::Tools::Toolbelt
                .instance
                .hash_tools
                .convert_keys_to_symbols(attributes)

            super(**self.class.members.to_h { |key| [key, attributes[key]] })
          end
        end
      end

      example_class 'Spec::BookEntity' do |klass|
        klass.include Stannum::Entity

        klass.define_primary_key :id,     Integer
        klass.define_attribute   :title,  String
        klass.define_attribute   :author, String
        klass.define_attribute   :series, String, optional: true
      end

      it { expect(query.convert(native)).to be_a Spec::BookEntity }

      it { expect(query.convert(native).attributes).to be == attributes }

      context 'when the adapter cannot build an entity' do
        let(:adapter) { Spec::ErrorAdapter.new }
        let(:error_message) do
          error      = adapter.build(attributes:).error
          attributes =
            SleepingKingStudios::Tools::Toolbelt
              .instance
              .hash_tools
              .convert_keys_to_symbols(self.attributes)

          <<~TEXT.strip
            Unable to process query data - #{error.message}
              error details: #{error.as_json}
              raw data: #{native.inspect}
              attributes: #{attributes.inspect}
          TEXT
        end

        example_class 'Spec::ErrorAdapter', Cuprum::Collections::Adapter \
        do |klass|
          klass.define_method(:build_entity) do |**|
            error = Cuprum::Error.new(message: 'something went wrong')

            failure(error)
          end
        end

        it 'should raise an exception' do
          expect { query.convert(native) }
            .to raise_error(described_class::InvalidDataError, error_message)
        end
      end
    end
  end

  describe '#scope' do
    it 'should define the default scope' do
      expect(query.scope).to be_a Cuprum::Collections::Scopes::AllScope
    end

    wrap_context 'when initialized with a scope' do
      it 'should transform the scope' do
        expect(query.scope).to be_a Cuprum::Collections::Scopes::CriteriaScope
      end
    end
  end
end
