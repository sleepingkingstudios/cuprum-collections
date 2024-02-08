# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts'
require 'cuprum/collections/rspec/fixtures'
require 'cuprum/collections/scope'

module Cuprum::Collections::RSpec::Contracts
  # Contracts for asserting on scope objects.
  module ScopeContracts
    # Contract validating the behavior of a scope implementation.
    module ShouldBeAScopeContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, invertible: false)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param invertible [Boolean] if true, the scope defines an
      #     implementation of the #invert method. Defaults to false.
      contract do |invertible: false|
        describe '#==' do
          it { expect(subject == nil).to be false } # rubocop:disable Style/NilComparison

          it { expect(subject == Object.new.freeze).to be false }

          describe 'with a scope of different type' do
            let(:other) { Spec::OtherScope.new }

            # rubocop:disable Style/RedundantLineContinuation
            example_class 'Spec::OtherScope',
              Cuprum::Collections::Scopes::Base \
            do |klass|
              klass.define_method(:type) { :invalid }
            end
            # rubocop:enable Style/RedundantLineContinuation

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

          next if invertible

          it 'should raise an exception' do
            expect { subject.invert }.to raise_error error_class, error_message
          end
        end

        describe '#type' do
          include_examples 'should define reader', :type, -> { be_a(Symbol) }
        end
      end
    end

    # Contract validating the behavior of a Container scope implementation.
    module ShouldBeAContainerScopeContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, invertible: false)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param invertible [Boolean] if true, the scope defines an
      #     implementation of the #invert method. Defaults to false.
      contract do |invertible: false|
        shared_context 'with scopes' do
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

        include_contract 'should be a scope', invertible: invertible

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

            wrap_context 'with scopes' do
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

            # rubocop:disable Style/RedundantLineContinuation
            example_class 'Spec::CustomScope',
              Cuprum::Collections::Scopes::Base \
            do |klass|
              klass.include Cuprum::Collections::Scopes::Container
            end
            # rubocop:enable Style/RedundantLineContinuation

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

            wrap_context 'with scopes' do
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

          wrap_context 'with scopes' do
            let(:expected) { subject.scopes.map(&:as_json) }

            it { expect(subject.as_json['scopes']).to be == expected }
          end
        end

        describe '#empty?' do
          it { expect(subject.empty?).to be true }

          wrap_context 'with scopes' do
            it { expect(subject.empty?).to be false }
          end
        end

        describe '#scopes' do
          include_examples 'should define reader', :scopes, -> { scopes }

          wrap_context 'with scopes' do
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

          wrap_context 'with scopes' do
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
    end

    # Contract validating the behavior of an All scope implementation.
    module ShouldBeAnAllScopeContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, abstract: false)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param abstract [Boolean] if true, the scope is abstract and does not
      #     define a #call implementation. Defaults to false.
      contract do |abstract: false|
        include_contract 'should be a scope', invertible: true

        describe '#==' do
          describe 'with a scope with the same class' do
            let(:other) { described_class.new }

            it { expect(subject == other).to be true }
          end

          describe 'with a scope with the same type' do
            let(:other) { Spec::CustomScope.new }

            # rubocop:disable Style/RedundantLineContinuation
            example_class 'Spec::CustomScope',
              Cuprum::Collections::Scopes::Base \
            do |klass|
              klass.define_method(:type) { :all }
            end
            # rubocop:enable Style/RedundantLineContinuation

            it { expect(subject == other).to be true }
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

          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:expected) do
              Cuprum::Collections::Scope.new(&block)
            end

            it { expect(subject.and(&block)).to be == expected }
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:expected) do
              Cuprum::Collections::Scope.new(value)
            end

            it { expect(subject.and(value)).to be == expected }
          end

          describe 'with an all scope' do
            let(:original) do
              Cuprum::Collections::Scopes::AllScope.new
            end

            it { expect(subject.and(original)).to be == original }
          end

          describe 'with a none scope' do
            let(:original) do
              Cuprum::Collections::Scopes::NoneScope.new
            end

            it { expect(subject.and(original)).to be == original }
          end

          describe 'with an empty conjunction scope' do
            let(:original) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(scopes: [])
            end

            it { expect(subject.and(original)).to be subject }
          end

          describe 'with an empty criteria scope' do
            let(:original) do
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: [])
            end

            it { expect(subject.and(original)).to be subject }
          end

          describe 'with an empty disjunction scope' do
            let(:original) do
              Cuprum::Collections::Scopes::DisjunctionScope.new(scopes: [])
            end

            it { expect(subject.and(original)).to be subject }
          end

          describe 'with an empty negation scope' do
            let(:original) do
              Cuprum::Collections::Scopes::NegationScope.new(scopes: [])
            end

            it { expect(subject.and(original)).to be subject }
          end

          describe 'with a non-empty conjunction scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::ConjunctionScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.and(original)).to be == original }
          end

          describe 'with a non-empty criteria scope' do
            let(:original) do
              Cuprum::Collections::Scope
                .new({ 'title' => 'A Wizard of Earthsea' })
            end

            it { expect(subject.and(original)).to be == original }
          end

          describe 'with a non-empty disjunction scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::DisjunctionScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.and(original)).to be == original }
          end

          describe 'with a non-empty negation scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::NegationScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.and(original)).to be == original }
          end
        end

        describe '#as_json' do
          let(:expected) { { 'type' => subject.type } }

          it { expect(subject.as_json).to be == expected }
        end

        describe '#call' do
          shared_context 'with data' do
            let(:data) do
              Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            end
          end

          next if abstract

          describe 'with empty data' do
            let(:data)     { [] }
            let(:expected) { data }

            it { expect(filtered_data).to be == expected }
          end

          wrap_context 'with data' do
            let(:expected) { data }

            it { expect(filtered_data).to be == expected }
          end
        end

        describe '#empty?' do
          it { expect(subject.empty?).to be false }
        end

        describe '#invert' do
          let(:expected) { Cuprum::Collections::Scopes::NoneScope.new }

          it { expect(subject.invert).to be == expected }
        end

        describe '#not' do
          it 'should define the method' do
            expect(subject)
              .to respond_to(:not)
              .with(0..1).arguments
              .and_a_block
          end

          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:expected) do
              wrapped = Cuprum::Collections::Scope.new(&block)

              Cuprum::Collections::Scopes::NegationScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.not(&block)).to be == expected }
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:expected) do
              wrapped = Cuprum::Collections::Scope.new(value)

              Cuprum::Collections::Scopes::NegationScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.not(value)).to be == expected }
          end

          describe 'with an all scope' do
            let(:original) do
              Cuprum::Collections::Scopes::AllScope.new
            end
            let(:expected) do
              Cuprum::Collections::Scopes::NoneScope.new
            end

            it { expect(subject.not(original)).to be == expected }
          end

          describe 'with a none scope' do
            let(:original) do
              Cuprum::Collections::Scopes::NoneScope.new
            end

            it { expect(subject.not(original)).to be subject }
          end

          describe 'with an empty conjunction scope' do
            let(:original) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(scopes: [])
            end

            it { expect(subject.not(original)).to be subject }
          end

          describe 'with an empty criteria scope' do
            let(:original) do
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: [])
            end

            it { expect(subject.not(original)).to be subject }
          end

          describe 'with an empty disjunction scope' do
            let(:original) do
              Cuprum::Collections::Scopes::DisjunctionScope.new(scopes: [])
            end

            it { expect(subject.not(original)).to be subject }
          end

          describe 'with an empty negation scope' do
            let(:original) do
              Cuprum::Collections::Scopes::NegationScope.new(scopes: [])
            end

            it { expect(subject.not(original)).to be subject }
          end

          describe 'with a non-empty conjunction scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::ConjunctionScope
                .new(scopes: [wrapped])
            end
            let(:expected) do
              Cuprum::Collections::Scopes::NegationScope
                .new(scopes: original.scopes)
            end

            it { expect(subject.not(original)).to be == expected }
          end

          describe 'with a non-empty criteria scope' do
            let(:original) do
              Cuprum::Collections::Scope
                .new({ 'title' => 'A Wizard of Earthsea' })
            end
            let(:expected) do
              Cuprum::Collections::Scopes::NegationScope
                .new(scopes: [original])
            end

            it { expect(subject.not(original)).to be == expected }
          end

          describe 'with a non-empty disjunction scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::DisjunctionScope
                .new(scopes: [wrapped])
            end
            let(:expected) do
              Cuprum::Collections::Scopes::NegationScope
                .new(scopes: [original])
            end

            it { expect(subject.not(original)).to be == expected }
          end

          describe 'with a negation scope with one child scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::NegationScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.not(original)).to be == original.scopes.first }
          end

          describe 'with a negation scope with many child scopes' do
            let(:original) do
              wrapped = Array.new(3) do
                Cuprum::Collections::Scope.new({ 'ok' => true })
              end

              Cuprum::Collections::Scopes::NegationScope
                .new(scopes: wrapped)
            end
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope
                .new(scopes: original.scopes)
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

          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:expected) do
              Cuprum::Collections::Scope.new(&block)
            end

            it { expect(subject.or(&block)).to be == expected }
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:expected) do
              Cuprum::Collections::Scope.new(value)
            end

            it { expect(subject.or(value)).to be == expected }
          end

          describe 'with an all scope' do
            let(:original) do
              Cuprum::Collections::Scopes::AllScope.new
            end

            it { expect(subject.and(original)).to be == original }
          end

          describe 'with an empty conjunction scope' do
            let(:original) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(scopes: [])
            end

            it { expect(subject.or(original)).to be subject }
          end

          describe 'with an empty criteria scope' do
            let(:original) do
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: [])
            end

            it { expect(subject.or(original)).to be subject }
          end

          describe 'with an empty disjunction scope' do
            let(:original) do
              Cuprum::Collections::Scopes::DisjunctionScope.new(scopes: [])
            end

            it { expect(subject.or(original)).to be subject }
          end

          describe 'with an empty negation scope' do
            let(:original) do
              Cuprum::Collections::Scopes::NegationScope.new(scopes: [])
            end

            it { expect(subject.or(original)).to be subject }
          end

          describe 'with a non-empty conjunction scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::ConjunctionScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.or(original)).to be == original }
          end

          describe 'with a non-empty criteria scope' do
            let(:original) do
              Cuprum::Collections::Scope
                .new({ 'title' => 'A Wizard of Earthsea' })
            end

            it { expect(subject.or(original)).to be == original }
          end

          describe 'with a non-empty disjunction scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::DisjunctionScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.or(original)).to be == original }
          end

          describe 'with a non-empty negation scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::NegationScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.or(original)).to be == original }
          end
        end

        describe '#type' do
          it { expect(subject.type).to be :all }
        end
      end
    end

    # Contract validating the behavior of a None scope implementation.
    module ShouldBeANoneScopeContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, abstract: false)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param abstract [Boolean] if true, the scope is abstract and does not
      #     define a #call implementation. Defaults to false.
      contract do |abstract: false|
        include_contract 'should be a scope', invertible: true

        describe '#==' do
          describe 'with a scope with the same class' do
            let(:other) { described_class.new }

            it { expect(subject == other).to be true }
          end

          describe 'with a scope with the same type' do
            let(:other) { Spec::CustomScope.new }

            # rubocop:disable Style/RedundantLineContinuation
            example_class 'Spec::CustomScope',
              Cuprum::Collections::Scopes::Base \
            do |klass|
              klass.define_method(:type) { :none }
            end
            # rubocop:enable Style/RedundantLineContinuation

            it { expect(subject == other).to be true }
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

          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }

            it { expect(subject.and(&block)).to be subject }
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }

            it { expect(subject.and(value)).to be subject }
          end

          describe 'with an all scope' do
            let(:original) do
              Cuprum::Collections::Scopes::AllScope.new
            end

            it { expect(subject.and(original)).to be subject }
          end

          describe 'with a none scope' do
            let(:original) do
              Cuprum::Collections::Scopes::NoneScope.new
            end

            it { expect(subject.and(original)).to be subject }
          end

          describe 'with an empty conjunction scope' do
            let(:original) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(scopes: [])
            end

            it { expect(subject.and(original)).to be subject }
          end

          describe 'with an empty criteria scope' do
            let(:original) do
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: [])
            end

            it { expect(subject.and(original)).to be subject }
          end

          describe 'with an empty disjunction scope' do
            let(:original) do
              Cuprum::Collections::Scopes::DisjunctionScope.new(scopes: [])
            end

            it { expect(subject.and(original)).to be subject }
          end

          describe 'with an empty negation scope' do
            let(:original) do
              Cuprum::Collections::Scopes::NegationScope.new(scopes: [])
            end

            it { expect(subject.and(original)).to be subject }
          end

          describe 'with a non-empty conjunction scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::ConjunctionScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.and(original)).to be subject }
          end

          describe 'with a non-empty criteria scope' do
            let(:original) do
              Cuprum::Collections::Scope
                .new({ 'title' => 'A Wizard of Earthsea' })
            end

            it { expect(subject.and(original)).to be subject }
          end

          describe 'with a non-empty disjunction scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::DisjunctionScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.and(original)).to be subject }
          end

          describe 'with a non-empty negation scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::NegationScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.and(original)).to be subject }
          end
        end

        describe '#as_json' do
          let(:expected) { { 'type' => subject.type } }

          it { expect(subject.as_json).to be == expected }
        end

        describe '#call' do
          shared_context 'with data' do
            let(:data) do
              Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            end
          end

          next if abstract

          describe 'with empty data' do
            let(:data)     { [] }
            let(:expected) { data }

            it { expect(filtered_data).to be == expected }
          end

          wrap_context 'with data' do
            let(:expected) { [] }

            it { expect(filtered_data).to be == expected }
          end
        end

        describe '#empty?' do
          it { expect(subject.empty?).to be false }
        end

        describe '#invert' do
          let(:expected) { Cuprum::Collections::Scopes::AllScope.new }

          it { expect(subject.invert).to be == expected }
        end

        describe '#not' do
          it 'should define the method' do
            expect(subject)
              .to respond_to(:not)
              .with(0..1).arguments
              .and_a_block
          end

          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }

            it { expect(subject.not(&block)).to be subject }
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }

            it { expect(subject.not(value)).to be subject }
          end

          describe 'with an all scope' do
            let(:original) do
              Cuprum::Collections::Scopes::AllScope.new
            end

            it { expect(subject.not(original)).to be subject }
          end

          describe 'with a none scope' do
            let(:original) do
              Cuprum::Collections::Scopes::AllScope.new
            end

            it { expect(subject.not(original)).to be subject }
          end

          describe 'with an empty conjunction scope' do
            let(:original) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(scopes: [])
            end

            it { expect(subject.not(original)).to be subject }
          end

          describe 'with an empty criteria scope' do
            let(:original) do
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: [])
            end

            it { expect(subject.not(original)).to be subject }
          end

          describe 'with an empty disjunction scope' do
            let(:original) do
              Cuprum::Collections::Scopes::DisjunctionScope.new(scopes: [])
            end

            it { expect(subject.not(original)).to be subject }
          end

          describe 'with an empty negation scope' do
            let(:original) do
              Cuprum::Collections::Scopes::NegationScope.new(scopes: [])
            end

            it { expect(subject.not(original)).to be subject }
          end

          describe 'with a non-empty conjunction scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::ConjunctionScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.not(original)).to be subject }
          end

          describe 'with a non-empty criteria scope' do
            let(:original) do
              Cuprum::Collections::Scope
                .new({ 'title' => 'A Wizard of Earthsea' })
            end

            it { expect(subject.not(original)).to be subject }
          end

          describe 'with a non-empty disjunction scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::DisjunctionScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.not(original)).to be subject }
          end

          describe 'with a negation scope with one child scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::NegationScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.not(original)).to be subject }
          end

          describe 'with a negation scope with many child scopes' do
            let(:original) do
              wrapped = Array.new(3) do
                Cuprum::Collections::Scope.new({ 'ok' => true })
              end

              Cuprum::Collections::Scopes::NegationScope
                .new(scopes: wrapped)
            end

            it { expect(subject.not(original)).to be subject }
          end
        end

        describe '#or' do
          it 'should define the method' do
            expect(subject)
              .to respond_to(:or)
              .with(0..1).arguments
              .and_a_block
          end

          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:expected) do
              Cuprum::Collections::Scope.new(&block)
            end

            it { expect(subject.or(&block)).to be == expected }
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:expected) do
              Cuprum::Collections::Scope.new(value)
            end

            it { expect(subject.or(value)).to be == expected }
          end

          describe 'with an all scope' do
            let(:original) do
              Cuprum::Collections::Scopes::AllScope.new
            end

            it { expect(subject.or(original)).to be == original }
          end

          describe 'with a none scope' do
            let(:original) do
              Cuprum::Collections::Scopes::NoneScope.new
            end

            it { expect(subject.or(original)).to be == original }
          end

          describe 'with an empty conjunction scope' do
            let(:original) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(scopes: [])
            end

            it { expect(subject.or(original)).to be subject }
          end

          describe 'with an empty criteria scope' do
            let(:original) do
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: [])
            end

            it { expect(subject.or(original)).to be subject }
          end

          describe 'with an empty disjunction scope' do
            let(:original) do
              Cuprum::Collections::Scopes::DisjunctionScope.new(scopes: [])
            end

            it { expect(subject.or(original)).to be subject }
          end

          describe 'with an empty negation scope' do
            let(:original) do
              Cuprum::Collections::Scopes::NegationScope.new(scopes: [])
            end

            it { expect(subject.or(original)).to be subject }
          end

          describe 'with a non-empty conjunction scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::ConjunctionScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.or(original)).to be == original }
          end

          describe 'with a non-empty criteria scope' do
            let(:original) do
              Cuprum::Collections::Scope
                .new({ 'title' => 'A Wizard of Earthsea' })
            end

            it { expect(subject.or(original)).to be == original }
          end

          describe 'with a non-empty disjunction scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::DisjunctionScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.or(original)).to be == original }
          end

          describe 'with a non-empty negation scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scope
                  .new({ 'title' => 'A Wizard of Earthsea' })

              Cuprum::Collections::Scopes::NegationScope
                .new(scopes: [wrapped])
            end

            it { expect(subject.or(original)).to be == original }
          end
        end

        describe '#type' do
          it { expect(subject.type).to be :none }
        end
      end
    end
  end
end
