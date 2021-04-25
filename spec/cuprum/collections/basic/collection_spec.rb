# frozen_string_literal: true

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/rspec/collection_contract'
require 'cuprum/collections/rspec/fixtures'

RSpec.describe Cuprum::Collections::Basic::Collection do
  subject(:collection) do
    described_class.new(
      collection_name: collection_name,
      data:            data,
      **constructor_options
    )
  end

  let(:collection_name)     { 'books' }
  let(:data)                { Cuprum::Collections::RSpec::BOOKS_FIXTURES }
  let(:constructor_options) { {} }

  def self.command_options
    %i[
      collection_name
      data
      default_contract
      member_name
      options
      primary_key_name
      primary_key_type
    ].freeze
  end

  def self.commands_namespace
    Cuprum::Collections::Basic::Commands
  end

  def tools
    SleepingKingStudios::Tools::Toolbelt.instance
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:collection_name, :data)
        .and_any_keywords
    end
  end

  include_contract Cuprum::Collections::RSpec::COLLECTION_CONTRACT

  describe '#collection_name' do
    include_examples 'should have reader',
      :collection_name,
      -> { collection_name }

    context 'when initialized with collection_name: symbol' do
      let(:collection_name) { :books }

      it { expect(collection.collection_name).to be == collection_name.to_s }
    end
  end

  describe '#data' do
    include_examples 'should define reader', :data, -> { data }
  end

  describe '#default_contract' do
    include_examples 'should define reader', :default_contract, nil

    context 'when initialized with a default contract' do
      let(:default_contract) { Stannum::Contract.new }
      let(:constructor_options) do
        super().merge(default_contract: default_contract)
      end

      it { expect(collection.default_contract).to be default_contract }
    end
  end

  describe '#member_name' do
    include_examples 'should have reader',
      :member_name,
      -> { tools.str.singularize(collection_name) }

    context 'when initialized with collection_name: value' do
      let(:collection_name) { :books }

      it 'should return the singular collection name' do
        expect(collection.member_name)
          .to be == tools.str.singularize(collection_name.to_s)
      end
    end

    context 'when initialized with member_name: string' do
      let(:member_name)         { 'tome' }
      let(:constructor_options) { super().merge(member_name: member_name) }

      it 'should return the singular collection name' do
        expect(collection.member_name).to be member_name
      end
    end

    context 'when initialized with member_name: symbol' do
      let(:member_name)         { :tome }
      let(:constructor_options) { super().merge(member_name: member_name) }

      it 'should return the singular collection name' do
        expect(collection.member_name).to be == member_name.to_s
      end
    end
  end

  describe '#options' do
    let(:expected_options) do
      defined?(super()) ? super() : constructor_options
    end

    include_examples 'should define reader',
      :options,
      -> { be == expected_options }

    context 'when initialized with options' do
      let(:constructor_options) { super().merge({ key: 'value' }) }
      let(:expected_options)    { super().merge({ key: 'value' }) }

      it { expect(collection.options).to be == expected_options }
    end
  end

  describe '#primary_key_name' do
    include_examples 'should define reader', :primary_key_name, :id

    context 'when initialized with a primary key name' do
      let(:primary_key_name) { :uuid }
      let(:constructor_options) do
        super().merge({ primary_key_name: primary_key_name })
      end

      it { expect(collection.primary_key_name).to be == primary_key_name }
    end
  end

  describe '#primary_key_type' do
    include_examples 'should define reader', :primary_key_type, Integer

    context 'when initialized with a primary key type' do
      let(:primary_key_type) { String }
      let(:constructor_options) do
        super().merge({ primary_key_type: primary_key_type })
      end

      it { expect(collection.primary_key_type).to be == primary_key_type }
    end
  end
end
