# frozen_string_literal: true

require 'cuprum/collections/rspec'

module Cuprum::Collections::RSpec
  # Contract validating the behavior of a Repository.
  REPOSITORY_CONTRACT = lambda do
    describe '#[]' do
      let(:error_class) do
        described_class::UndefinedCollectionError
      end
      let(:error_message) do
        "repository does not define collection #{collection_name.inspect}"
      end

      it { expect(repository).to respond_to(:[]).with(1).argument }

      describe 'with nil' do
        let(:collection_name) { nil }

        it 'should raise an exception' do
          expect { repository[collection_name] }
            .to raise_error(error_class, error_message)
        end
      end

      describe 'with an object' do
        let(:collection_name) { Object.new.freeze }

        it 'should raise an exception' do
          expect { repository[collection_name] }
            .to raise_error(error_class, error_message)
        end
      end

      describe 'with an invalid string' do
        let(:collection_name) { 'invalid_name' }

        it 'should raise an exception' do
          expect { repository[collection_name] }
            .to raise_error(error_class, error_message)
        end
      end

      describe 'with an invalid symbol' do
        let(:collection_name) { :invalid_name }

        it 'should raise an exception' do
          expect { repository[collection_name] }
            .to raise_error(error_class, error_message)
        end
      end

      wrap_context 'when the repository has many collections' do
        describe 'with an invalid string' do
          let(:collection_name) { 'invalid_name' }

          it 'should raise an exception' do
            expect { repository[collection_name] }
              .to raise_error(error_class, error_message)
          end
        end

        describe 'with an invalid symbol' do
          let(:collection_name) { :invalid_name }

          it 'should raise an exception' do
            expect { repository[collection_name] }
              .to raise_error(error_class, error_message)
          end
        end

        describe 'with a valid string' do
          let(:collection)      { collections.values.first }
          let(:collection_name) { collections.keys.first }

          it { expect(repository[collection_name]).to be collection }
        end

        describe 'with a valid symbol' do
          let(:collection)      { collections.values.first }
          let(:collection_name) { collections.keys.first.intern }

          it { expect(repository[collection_name]).to be collection }
        end
      end
    end

    describe '#add' do
      let(:error_class) do
        described_class::InvalidCollectionError
      end
      let(:error_message) do
        "#{collection.inspect} is not a valid collection"
      end

      it 'should define the method' do
        expect(repository)
          .to respond_to(:add)
          .with(1).argument
          .and_keywords(:force)
      end

      it 'should alias #add as #<<' do
        expect(repository.method(:<<)).to be == repository.method(:add)
      end

      describe 'with nil' do
        let(:collection) { nil }

        it 'should raise an exception' do
          expect { repository.add(collection) }
            .to raise_error(error_class, error_message)
        end
      end

      describe 'with an object' do
        let(:collection) { Object.new.freeze }

        it 'should raise an exception' do
          expect { repository.add(collection) }
            .to raise_error(error_class, error_message)
        end
      end

      describe 'with a collection' do
        it { expect(repository.add(example_collection)).to be repository }

        it 'should add the collection to the repository' do
          repository.add(example_collection)

          expect(repository[example_collection.collection_name])
            .to be example_collection
        end

        describe 'with force: true' do
          it 'should add the collection to the repository' do
            repository.add(example_collection, force: true)

            expect(repository[example_collection.collection_name])
              .to be example_collection
          end
        end

        context 'when the collection already exists' do
          let(:error_message) do
            "collection #{example_collection.collection_name} already exists"
          end

          before(:example) do
            allow(repository)
              .to receive(:key?)
              .with(example_collection.collection_name)
              .and_return(true)
          end

          it 'should raise an exception' do
            expect { repository.add(example_collection) }
              .to raise_error(
                described_class::DuplicateCollectionError,
                error_message
              )
          end

          it 'should not update the repository' do
            begin
              repository.add(example_collection)
            rescue described_class::DuplicateCollectionError
              # Do nothing.
            end

            expect { repository[example_collection.collection_name] }
              .to raise_error(
                described_class::UndefinedCollectionError,
                'repository does not define collection' \
                " #{example_collection.collection_name.inspect}"
              )
          end

          describe 'with force: true' do
            it 'should add the collection to the repository' do
              repository.add(example_collection, force: true)

              expect(repository[example_collection.collection_name])
                .to be example_collection
            end
          end
        end
      end
    end

    describe '#key?' do
      it { expect(repository).to respond_to(:key?).with(1).argument }

      it { expect(repository.key? nil).to be false }

      it { expect(repository.key? Object.new.freeze).to be false }

      it { expect(repository.key? 'invalid_name').to be false }

      it { expect(repository.key? :invalid_name).to be false }

      wrap_context 'when the repository has many collections' do
        it { expect(repository.key? 'invalid_name').to be false }

        it { expect(repository.key? :invalid_name).to be false }

        it { expect(repository.key? collections.keys.first).to be true }

        it { expect(repository.key? collections.keys.first.intern).to be true }
      end
    end

    describe '#keys' do
      include_examples 'should define reader', :keys, []

      wrap_context 'when the repository has many collections' do
        it { expect(repository.keys).to be == collections.keys }
      end
    end
  end
end
