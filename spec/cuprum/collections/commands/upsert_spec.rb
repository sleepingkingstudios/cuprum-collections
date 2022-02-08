# frozen_string_literal: true

require 'stannum/constraints/presence'
require 'stannum/contracts/hash_contract'

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/commands/upsert'

RSpec.describe Cuprum::Collections::Commands::Upsert do
  subject(:command) { described_class.new(**constructor_options) }

  shared_context 'when initialized with a contract' do
    let(:contract) do
      Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
        key 'series', Stannum::Constraints::Presence.new
      end
    end
    let(:constructor_options) { super().merge(contract: contract) }
  end

  shared_context 'when the collection defines a default contract' do
    let(:contract) do
      Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
        key 'author', Stannum::Constraints::Presence.new
      end
    end
    let(:collection_options) { super().merge(default_contract: contract) }
  end

  let(:collection) do
    Cuprum::Collections::Basic::Collection.new(
      collection_name: 'books',
      data:            [],
      **collection_options
    )
  end
  let(:collection_options)  { {} }
  let(:constructor_options) { { collection: collection } }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:attribute_names, :collection, :contract)
    end

    describe 'with attribute_names: nil' do
      let(:error_message) do
        "attribute names can't be blank"
      end
      let(:constructor_options) do
        super().merge(attribute_names: nil)
      end

      it 'should raise an exception' do
        expect { described_class.new(**constructor_options) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with attribute_names: an Object' do
      let(:attribute_names) { Object.new.freeze }
      let(:error_message) do
        "invalid attribute name #{attribute_names.inspect}"
      end
      let(:constructor_options) do
        super().merge(attribute_names: attribute_names)
      end

      it 'should raise an exception' do
        expect { described_class.new(**constructor_options) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with attribute_names: an empty Array' do
      let(:error_message) do
        "attribute names can't be blank"
      end
      let(:constructor_options) do
        super().merge(attribute_names: [])
      end

      it 'should raise an exception' do
        expect { described_class.new(**constructor_options) }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#attribute_names' do
    include_examples 'should define reader',
      :attribute_names,
      -> { be == Set.new(%w[id]) }

    context 'when initialized with attribute_names: a String' do
      let(:constructor_options) { super().merge(attribute_names: 'name') }

      it { expect(command.attribute_names).to be == Set.new(%w[name]) }
    end

    context 'when initialized with attribute_names: a Symbol' do
      let(:constructor_options) { super().merge(attribute_names: :name) }

      it { expect(command.attribute_names).to be == Set.new(%w[name]) }
    end

    context 'when initialized with attribute_names: an Array of Strings' do
      let(:attribute_names) { %w[title author] }
      let(:constructor_options) do
        super().merge(attribute_names: attribute_names)
      end

      it { expect(command.attribute_names).to be == Set.new(attribute_names) }
    end

    context 'when initialized with attribute_names: an Array of Symbols' do
      let(:attribute_names) { %i[title author] }
      let(:expected)        { attribute_names.map(&:to_s) }
      let(:constructor_options) do
        super().merge(attribute_names: attribute_names)
      end

      it { expect(command.attribute_names).to be == Set.new(expected) }
    end
  end

  describe '#call' do
    shared_examples 'should find and update or create the entity' do
      context 'when no matching entity exists' do
        describe 'with an invalid attributes Hash' do
          let(:attributes) { super().merge(invalid_attributes) }
          let(:expected_error) do
            errors = contract.errors_for(attributes)

            Cuprum::Collections::Errors::FailedValidation.new(
              entity_class: Hash,
              errors:       errors
            )
          end

          it 'should return a failing result' do
            expect(command.call(attributes: attributes))
              .to be_a_failing_result
              .with_error(expected_error)
          end

          it 'should not add an entity to the collection' do
            expect { command.call(attributes: attributes) }
              .not_to(change { collection.query.count })
          end
        end

        describe 'with a valid attributes Hash' do
          let(:attributes)     { super().merge(valid_attributes) }
          let(:expected_value) { attributes }

          it 'should return a passing result' do
            expect(command.call(attributes: attributes))
              .to be_a_passing_result
              .with_value(expected_value)
          end

          it 'should add an entity to the collection' do
            expect { command.call(attributes: attributes) }
              .to(
                change { collection.query.count }
                .by(1)
              )
          end

          it 'should create the entity' do # rubocop:disable RSpec/ExampleLength
            expected_attributes = attributes

            command.call(attributes: attributes)

            expect(
              collection
              .query
              .where { expected_attributes }
              .exists?
            ).to be true
          end
        end
      end

      context 'when a matching entity exists' do
        before(:example) { collection.insert_one.call(entity: matching_entity) }

        describe 'with an invalid attributes Hash' do
          let(:attributes) { super().merge(invalid_attributes) }
          let(:expected_error) do
            errors = contract.errors_for(attributes)

            Cuprum::Collections::Errors::FailedValidation.new(
              entity_class: Hash,
              errors:       errors
            )
          end

          it 'should return a failing result' do
            expect(command.call(attributes: attributes))
              .to be_a_failing_result
              .with_error(expected_error)
          end

          it 'should not update the attributes' do
            expect { command.call(attributes: attributes) }
              .not_to(change { reload_attributes })
          end
        end

        describe 'with a valid attributes Hash' do
          let(:attributes)     { super().merge(valid_attributes) }
          let(:expected_value) { matching_entity.merge(attributes) }

          it 'should return a passing result' do
            expect(command.call(attributes: attributes))
              .to be_a_passing_result
              .with_value(expected_value)
          end

          it 'should update the attributes' do
            expect { command.call(attributes: attributes) }
              .to(
                change { reload_attributes }
                .to be == expected_value
              )
          end
        end
      end
    end

    let(:filter_attributes) { { 'id' => 0 } }
    let(:attributes)        { filter_attributes }
    let(:matching_entity) do
      {
        'id'     => 0,
        'author' => 'Becky Chambers',
        'title'  => 'The Long Way To A Small, Angry Planet'
      }
    end
    let(:expected_error) do
      Cuprum::Collections::Errors::MissingDefaultContract
        .new(entity_class: Hash)
    end

    def reload_attributes
      filter = filter_attributes

      collection
        .find_matching
        .call { filter }
        .value
        .first
    end

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:attributes)
    end

    it 'should return a failing result' do
      expect(command.call(attributes: {}))
        .to be_a_failing_result
        .with_error(expected_error)
    end

    wrap_context 'when initialized with a contract' do
      let(:invalid_attributes) { { 'series' => '' } }
      let(:valid_attributes) do
        {
          'author' => '',
          'series' => 'The Locked Tomb'
        }
      end

      include_examples 'should find and update or create the entity'
    end

    wrap_context 'when the collection defines a default contract' do
      let(:invalid_attributes) { { 'author' => '' } }
      let(:valid_attributes) do
        {
          'author' => 'Tamsyn Muir',
          'series' => ''
        }
      end

      include_examples 'should find and update or create the entity'
    end

    context 'when initialized with attribute_names: value' do
      let(:constructor_options) do
        super().merge(attribute_names: :title)
      end
      let(:filter_attributes) { { 'title' => 'Gideon the Ninth' } }
      let(:matching_entity) do
        {
          'id'     => 0,
          'title'  => 'Gideon the Ninth',
          'author' => '',
          'series' => ''
        }
      end

      wrap_context 'when initialized with a contract' do
        let(:invalid_attributes) { { 'series' => '' } }
        let(:valid_attributes) do
          {
            'author' => '',
            'series' => 'The Locked Tomb'
          }
        end

        include_examples 'should find and update or create the entity'

        context 'when there are multiple matching entities' do
          let(:matching_entities) do
            [
              {
                'id'     => 0,
                'title'  => 'Gideon the Ninth',
                'author' => 'Tamsyn Muir',
                'series' => ''
              },
              {
                'id'     => 1,
                'title'  => 'Gideon the Ninth',
                'author' => '',
                'series' => 'The Locked Tomb'
              }
            ]
          end
          let(:expected_error) do
            Cuprum::Collections::Errors::NotUnique.new(
              attributes:      filter_attributes,
              collection_name: collection.collection_name
            )
          end

          before(:example) do
            matching_entities.each do |matching_entity|
              collection.insert_one.call(entity: matching_entity)
            end
          end

          it 'should return a failing result' do
            expect(command.call(attributes: attributes))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end
      end

      wrap_context 'when the collection defines a default contract' do
        let(:invalid_attributes) { { 'author' => '' } }
        let(:valid_attributes) do
          {
            'author' => 'Tamsyn Muir',
            'series' => ''
          }
        end

        include_examples 'should find and update or create the entity'

        context 'when there are multiple matching entities' do
          let(:matching_entities) do
            [
              {
                'id'     => 0,
                'title'  => 'Gideon the Ninth',
                'author' => 'Tamsyn Muir',
                'series' => ''
              },
              {
                'id'     => 1,
                'title'  => 'Gideon the Ninth',
                'author' => '',
                'series' => 'The Locked Tomb'
              }
            ]
          end
          let(:expected_error) do
            Cuprum::Collections::Errors::NotUnique.new(
              attributes:      filter_attributes,
              collection_name: collection.collection_name
            )
          end

          before(:example) do
            matching_entities.each do |matching_entity|
              collection.insert_one.call(entity: matching_entity)
            end
          end

          it 'should return a failing result' do
            expect(command.call(attributes: attributes))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end
      end
    end

    context 'when initialized with attribute_names: an Array of values' do
      let(:constructor_options) do
        super().merge(attribute_names: %i[title category])
      end
      let(:filter_attributes) do
        {
          'title'    => 'Gideon the Ninth',
          'category' => 'Science Fiction and Fantasy'
        }
      end
      let(:matching_entity) do
        {
          'id'       => 0,
          'title'    => 'Gideon the Ninth',
          'author'   => '',
          'series'   => '',
          'category' => 'Science Fiction and Fantasy'
        }
      end

      wrap_context 'when initialized with a contract' do
        let(:invalid_attributes) { { 'series' => '' } }
        let(:valid_attributes) do
          {
            'author' => '',
            'series' => 'The Locked Tomb'
          }
        end

        include_examples 'should find and update or create the entity'

        context 'when there are multiple matching entities' do
          let(:matching_entities) do
            [
              {
                'id'       => 0,
                'title'    => 'Gideon the Ninth',
                'author'   => 'Tamsyn Muir',
                'series'   => '',
                'category' => 'Science Fiction and Fantasy'
              },
              {
                'id'       => 1,
                'title'    => 'Gideon the Ninth',
                'author'   => '',
                'series'   => 'The Locked Tomb',
                'category' => 'Science Fiction and Fantasy'
              }
            ]
          end
          let(:expected_error) do
            Cuprum::Collections::Errors::NotUnique.new(
              attributes:      filter_attributes,
              collection_name: collection.collection_name
            )
          end

          before(:example) do
            matching_entities.each do |matching_entity|
              collection.insert_one.call(entity: matching_entity)
            end
          end

          it 'should return a failing result' do
            expect(command.call(attributes: attributes))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end
      end

      wrap_context 'when the collection defines a default contract' do
        let(:invalid_attributes) { { 'author' => '' } }
        let(:valid_attributes) do
          {
            'author' => 'Tamsyn Muir',
            'series' => ''
          }
        end

        include_examples 'should find and update or create the entity'

        context 'when there are multiple matching entities' do
          let(:matching_entities) do
            [
              {
                'id'       => 0,
                'title'    => 'Gideon the Ninth',
                'author'   => 'Tamsyn Muir',
                'series'   => '',
                'category' => 'Science Fiction and Fantasy'
              },
              {
                'id'       => 1,
                'title'    => 'Gideon the Ninth',
                'author'   => '',
                'series'   => 'The Locked Tomb',
                'category' => 'Science Fiction and Fantasy'
              }
            ]
          end
          let(:expected_error) do
            Cuprum::Collections::Errors::NotUnique.new(
              attributes:      filter_attributes,
              collection_name: collection.collection_name
            )
          end

          before(:example) do
            matching_entities.each do |matching_entity|
              collection.insert_one.call(entity: matching_entity)
            end
          end

          it 'should return a failing result' do
            expect(command.call(attributes: attributes))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end
      end
    end
  end

  describe '#collection' do
    include_examples 'should define reader', :collection, -> { collection }
  end

  describe '#contract' do
    include_examples 'should define reader', :contract, nil

    wrap_context 'when initialized with a contract' do
      it { expect(command.contract).to be contract }
    end
  end
end
