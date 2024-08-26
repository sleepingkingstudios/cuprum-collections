# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/collections/rspec/deferred'

module Cuprum::Collections::RSpec::Deferred
  # Deferred examples for testing collection commands.
  module CommandExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should implement the CollectionCommand methods' do
      describe '#collection' do
        include_examples 'should define reader', :collection, -> { collection }
      end

      describe '#name' do
        include_examples 'should define reader', :name, -> { collection.name }

        it 'should alias the method' do
          expect(subject).to have_aliased_method(:name).as(:collection_name)
        end
      end

      describe '#primary_key_name' do
        include_examples 'should define reader',
          :primary_key_name,
          -> { collection.primary_key_name }
      end

      describe '#primary_key_type' do
        include_examples 'should define reader',
          :primary_key_type,
          -> { collection.primary_key_type }
      end

      describe '#query' do
        let(:mock_query) { instance_double(Cuprum::Collections::Query) }

        before(:example) do
          allow(collection).to receive(:query).and_return(mock_query)
        end

        it { expect(subject).to respond_to(:query).with(0).arguments }

        it { expect(subject.query).to be mock_query }
      end

      describe '#singular_name' do
        include_examples 'should define reader',
          :singular_name,
          -> { collection.singular_name }

        it 'should alias the method' do
          expect(subject)
            .to have_aliased_method(:singular_name)
            .as(:member_name)
        end
      end
    end
  end
end
