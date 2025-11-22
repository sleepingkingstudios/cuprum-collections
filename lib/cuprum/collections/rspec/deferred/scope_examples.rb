# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/collections/rspec/deferred'

module Cuprum::Collections::RSpec::Deferred
  # Deferred examples for asserting on scope objects.
  module ScopeExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should implement the Scope methods' \
    do |**deferred_options|
      describe '#==' do
        it { expect(subject == nil).to be false } # rubocop:disable Style/NilComparison

        it { expect(subject == Object.new.freeze).to be false }

        describe 'with a scope of different type' do
          let(:other) { Spec::OtherScope.new }

          example_class 'Spec::OtherScope',
            Cuprum::Collections::Scopes::Base \
          do |klass|
            klass.define_method(:type) { :invalid }
          end

          it { expect(subject == other).to be false }
        end
      end

      describe '#as_json' do
        it { expect(subject).to respond_to(:as_json).with(0).arguments }

        it { expect(subject.as_json).to be_a Hash }

        it { expect(subject.as_json['type']).to be subject.type }
      end

      describe '#empty?' do
        include_examples 'should define predicate', :empty?, -> { be_boolean }
      end

      describe '#invert' do
        let(:error_class) do
          Cuprum::Collections::Scopes::Base::UninvertibleScopeException
        end
        let(:error_message) do
          "Scope class #{described_class} does not implement #invert"
        end

        it { expect(subject).to respond_to(:invert).with(0).arguments }

        next if deferred_options.fetch(:invertible, true)

        it 'should raise an exception' do
          expect { subject.invert }.to raise_error error_class, error_message
        end
      end

      describe '#type' do
        include_examples 'should define reader', :type, -> { be_a(Symbol) }
      end
    end

    deferred_examples 'should define child scopes' do
      deferred_context 'with scopes' do
        let(:scopes) do
          [
            build_scope({ 'title'    => 'J.R.R. Tolkien' }),
            build_scope({ 'series'   => 'The Lord of the Rings' }),
            build_scope({ 'category' => 'Science Fiction and Fantasy' })
          ]
        end
      end

      describe '.new' do
        it 'should define the constructor' do
          expect(described_class)
            .to be_constructible
            .with(0).arguments
            .and_keywords(:scopes)
            .and_any_keywords
        end
      end

      describe '#==' do
        describe 'with a scope with the same class' do
          let(:other) { described_class.new(scopes: other_scopes) }

          describe 'with empty scopes' do
            let(:other_scopes) { [] }

            it { expect(subject == other).to be true }
          end

          describe 'with non-matching scopes' do
            let(:other_scopes) do
              Array.new(3) do
                Cuprum::Collections::Scope.new({ 'ok' => true })
              end
            end

            it { expect(subject == other).to be false }
          end

          wrap_deferred 'with scopes' do
            describe 'with empty scopes' do
              let(:other_scopes) { [] }

              it { expect(subject == other).to be false }
            end

            describe 'with non-matching scopes' do
              let(:other_scopes) do
                Array.new(3) do
                  Cuprum::Collections::Scope.new({ 'ok' => true })
                end
              end

              it { expect(subject == other).to be false }
            end

            describe 'with matching scopes' do
              let(:other_scopes) { subject.scopes }

              it { expect(subject == other).to be true }
            end
          end
        end

        describe 'with a scope with the same type' do
          let(:other) { Spec::CustomScope.new(scopes: other_scopes) }

          example_class 'Spec::CustomScope',
            Cuprum::Collections::Scopes::Base \
          do |klass|
            klass.include Cuprum::Collections::Scopes::Container
          end

          before(:example) do
            allow(other).to receive(:type).and_return(scope.type)
          end

          describe 'with empty scopes' do
            let(:other_scopes) { [] }

            it { expect(subject == other).to be true }
          end

          describe 'with non-matching scopes' do
            let(:other_scopes) do
              Array.new(3) do
                Cuprum::Collections::Scope.new({ 'ok' => true })
              end
            end

            it { expect(subject == other).to be false }
          end

          wrap_deferred 'with scopes' do
            describe 'with empty scopes' do
              let(:other_scopes) { [] }

              it { expect(subject == other).to be false }
            end

            describe 'with non-matching scopes' do
              let(:other_scopes) do
                Array.new(3) do
                  Cuprum::Collections::Scope.new({ 'ok' => true })
                end
              end

              it { expect(subject == other).to be false }
            end

            describe 'with matching scopes' do
              let(:other_scopes) { subject.scopes }

              it { expect(subject == other).to be true }
            end
          end
        end
      end

      describe '#as_json' do
        it { expect(subject.as_json['scopes']).to be == [] }

        wrap_deferred 'with scopes' do
          let(:expected) { subject.scopes.map(&:as_json) }

          it { expect(subject.as_json['scopes']).to be == expected }
        end
      end

      describe '#empty?' do
        it { expect(subject.empty?).to be true }

        wrap_deferred 'with scopes' do
          it { expect(subject.empty?).to be false }
        end
      end

      describe '#scopes' do
        include_examples 'should define reader', :scopes, -> { scopes }

        wrap_deferred 'with scopes' do
          it { expect(subject.scopes).to be == scopes }
        end
      end

      describe '#with_scopes' do
        let(:new_scopes) do
          [
            described_class.new(scopes: []),
            described_class.new(scopes: [])
          ]
        end

        it { expect(subject).to respond_to(:with_scopes).with(1).arguments }

        it 'should return a scope' do
          expect(subject.with_scopes(new_scopes)).to be_a described_class
        end

        it "should not change the original scope's child scopes" do
          expect { subject.with_scopes(new_scopes) }
            .not_to change(subject, :scopes)
        end

        it "should set the copied scope's child scopes" do
          expect(subject.with_scopes(new_scopes).scopes)
            .to be == new_scopes
        end

        wrap_deferred 'with scopes' do
          it "should not change the original scope's child scopes" do
            expect { subject.with_scopes(new_scopes) }
              .not_to change(subject, :scopes)
          end

          it "should set the copied scope's child scopes" do
            expect(subject.with_scopes(new_scopes).scopes)
              .to be == new_scopes
          end
        end
      end
    end

    deferred_examples 'should compose scopes' do |**deferred_options|
      deferred_context 'with an all scope' do
        let(:original) do
          Cuprum::Collections::Scopes::AllScope.new
        end
      end

      deferred_context 'with a none scope' do
        let(:original) do
          Cuprum::Collections::Scopes::NoneScope.new
        end
      end

      deferred_context 'with an empty conjunction scope' do
        let(:original) do
          Cuprum::Collections::Scopes::ConjunctionScope.new(scopes: [])
        end
      end

      deferred_context 'with an empty criteria scope' do
        let(:original) do
          Cuprum::Collections::Scopes::CriteriaScope.new(criteria: [])
        end
      end

      deferred_context 'with an empty disjunction scope' do
        let(:original) do
          Cuprum::Collections::Scopes::DisjunctionScope.new(scopes: [])
        end
      end

      deferred_context 'with a non-empty conjunction scope' do
        let(:original) do
          operators = Cuprum::Collections::Queries::Operators
          criteria  = [
            [
              'category',
              operators::EQUAL,
              'Science Fiction and Fantasy'
            ]
          ]
          wrapped =
            Cuprum::Collections::Scopes::CriteriaScope.new(criteria:)

          Cuprum::Collections::Scopes::ConjunctionScope.new(scopes: [wrapped])
        end
      end

      deferred_context 'with a non-empty criteria scope' do
        let(:original) do
          operators = Cuprum::Collections::Queries::Operators
          criteria  = [
            [
              'category',
              operators::EQUAL,
              'Science Fiction and Fantasy'
            ]
          ]

          Cuprum::Collections::Scopes::CriteriaScope.new(criteria:)
        end
      end

      deferred_context 'with a non-empty disjunction scope' do
        let(:original) do
          operators = Cuprum::Collections::Queries::Operators
          criteria  = [
            [
              'category',
              operators::EQUAL,
              'Science Fiction and Fantasy'
            ]
          ]
          wrapped =
            Cuprum::Collections::Scopes::CriteriaScope.new(criteria:)

          Cuprum::Collections::Scopes::DisjunctionScope.new(scopes: [wrapped])
        end
      end

      describe '#and' do
        it 'should define the method' do
          expect(subject)
            .to respond_to(:and)
            .with(0..1).arguments
            .and_a_block
        end

        it { expect(subject).to have_aliased_method(:and).as(:where) }

        next if deferred_options.fetch(:include, []).include?(:and)

        describe 'with a block' do
          let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
          let(:expected) do
            wrapped = Cuprum::Collections::Scope.new(&block)

            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [subject, wrapped]
            )
          end

          it { expect(subject.and(&block)).to be == expected }
        end

        describe 'with a hash' do
          let(:value) { { 'title' => 'A Wizard of Earthsea' } }
          let(:expected) do
            wrapped = Cuprum::Collections::Scope.new(value)

            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [subject, wrapped]
            )
          end

          it { expect(subject.and(value)).to be == expected }
        end

        wrap_deferred 'with an all scope' do
          it { expect(subject.and(original)).to be subject }
        end

        wrap_deferred 'with a none scope' do
          it { expect(subject.and(original)).to be == original }
        end

        wrap_deferred 'with an empty conjunction scope' do
          it { expect(subject.and(original)).to be subject }
        end

        wrap_deferred 'with an empty criteria scope' do
          it { expect(subject.and(original)).to be subject }
        end

        wrap_deferred 'with an empty disjunction scope' do
          it { expect(subject.and(original)).to be subject }
        end

        wrap_deferred 'with a non-empty conjunction scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [subject, *original.scopes]
            )
          end

          it { expect(subject.and(original)).to be == expected }
        end

        wrap_deferred 'with a non-empty criteria scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [subject, original]
            )
          end

          it { expect(subject.and(original)).to be == expected }
        end

        wrap_deferred 'with a non-empty disjunction scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [subject, original]
            )
          end

          it { expect(subject.and(original)).to be == expected }
        end
      end

      describe '#not' do
        it 'should define the method' do
          expect(subject)
            .to respond_to(:not)
            .with(0..1).arguments
            .and_a_block
        end

        next if deferred_options.fetch(:include, []).include?(:not)

        describe 'with a block' do
          let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
          let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
          let(:expected) do
            wrapped = Cuprum::Collections::Scope.new(&block)

            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [subject, wrapped.invert]
            )
          end

          it { expect(subject.not(&block)).to be == expected }
        end

        describe 'with a hash' do
          let(:value)  { { 'title' => 'A Wizard of Earthsea' } }
          let(:expected) do
            wrapped = Cuprum::Collections::Scope.new(value)

            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [subject, wrapped.invert]
            )
          end

          it { expect(subject.not(value)).to be == expected }
        end

        wrap_deferred 'with an all scope' do
          let(:expected) { Cuprum::Collections::Scopes::NoneScope.new }

          it { expect(subject.not(original)).to be == expected }
        end

        wrap_deferred 'with a none scope' do
          it { expect(subject.not(original)).to be subject }
        end

        wrap_deferred 'with an empty conjunction scope' do
          it { expect(subject.not(original)).to be subject }
        end

        wrap_deferred 'with an empty criteria scope' do
          it { expect(subject.not(original)).to be subject }
        end

        wrap_deferred 'with an empty disjunction scope' do
          it { expect(subject.not(original)).to be subject }
        end

        wrap_deferred 'with a non-empty conjunction scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [subject, original.invert]
            )
          end

          it { expect(subject.not(original)).to be == expected }
        end

        wrap_deferred 'with a non-empty criteria scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [subject, original.invert]
            )
          end

          it { expect(subject.not(original)).to be == expected }
        end

        wrap_deferred 'with a non-empty disjunction scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [subject, *original.invert.scopes]
            )
          end

          it { expect(subject.not(original)).to be == expected }
        end
      end

      describe '#or' do
        it 'should define the method' do
          expect(subject)
            .to respond_to(:or)
            .with(0..1).arguments
            .and_a_block
        end

        next if deferred_options.fetch(:include, []).include?(:or)

        describe 'with a block' do
          let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
          let(:expected) do
            wrapped = Cuprum::Collections::Scope.new(&block)

            Cuprum::Collections::Scopes::DisjunctionScope.new(
              scopes: [subject, wrapped]
            )
          end

          it { expect(subject.or(&block)).to be == expected }
        end

        describe 'with a hash' do
          let(:value) { { 'title' => 'A Wizard of Earthsea' } }
          let(:expected) do
            wrapped = Cuprum::Collections::Scope.new(value)

            Cuprum::Collections::Scopes::DisjunctionScope.new(
              scopes: [subject, wrapped]
            )
          end

          it { expect(subject.or(value)).to be == expected }
        end

        wrap_deferred 'with an all scope' do
          it { expect(subject.or(original)).to be == original }
        end

        wrap_deferred 'with a none scope' do
          it { expect(subject.or(original)).to be subject }
        end

        wrap_deferred 'with an empty conjunction scope' do
          it { expect(subject.or(original)).to be subject }
        end

        wrap_deferred 'with an empty criteria scope' do
          it { expect(subject.or(original)).to be subject }
        end

        wrap_deferred 'with an empty disjunction scope' do
          it { expect(subject.or(original)).to be subject }
        end

        wrap_deferred 'with a non-empty conjunction scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::DisjunctionScope.new(
              scopes: [subject, original]
            )
          end

          it { expect(subject.or(original)).to be == expected }
        end

        wrap_deferred 'with a non-empty criteria scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::DisjunctionScope.new(
              scopes: [subject, original]
            )
          end

          it { expect(subject.or(original)).to be == expected }
        end

        wrap_deferred 'with a non-empty disjunction scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::DisjunctionScope.new(
              scopes: [subject, *original.scopes]
            )
          end

          it { expect(subject.or(original)).to be == expected }
        end
      end
    end
  end
end
