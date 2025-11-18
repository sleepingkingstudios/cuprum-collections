# frozen_string_literal: true

require 'cuprum/collections/queries'
require 'cuprum/collections/rspec/deferred/scopes/builder_examples'
require 'cuprum/collections/scopes/building'
require 'cuprum/collections/scopes/conjunction_scope'
require 'cuprum/collections/scopes/criteria_scope'

RSpec.describe Cuprum::Collections::Scopes::Building do
  include Cuprum::Collections::RSpec::Deferred::Scopes::BuilderExamples

  subject(:builder) { described_class.instance }

  let(:described_class) { Spec::ScopeBuilder }

  example_class 'Spec::ScopeBuilder' do |klass|
    klass.include Cuprum::Collections::Scopes::Building # rubocop:disable RSpec/DescribedClass
  end

  define_method :build_scope do
    Cuprum::Collections::Scopes::CriteriaScope.new(criteria: [])
  end

  describe '::AbstractBuilderError' do
    include_examples 'should define constant', :AbstractBuilderError

    it { expect(described_class::AbstractBuilderError).to be_a Class }

    it 'should inherit from StandardError' do
      expect(described_class::AbstractBuilderError).to be < StandardError
    end
  end

  describe '::UnknownScopeTypeError' do
    include_examples 'should define constant', :UnknownScopeTypeError

    it { expect(described_class::UnknownScopeTypeError).to be_a Class }

    it 'should inherit from StandardError' do
      expect(described_class::UnknownScopeTypeError).to be < StandardError
    end
  end

  include_deferred 'should be a Scope builder', abstract: true

  describe '#build' do
    let(:error_class) do
      Cuprum::Collections::Scopes::Building::AbstractBuilderError
    end

    describe 'with a block' do
      let(:block) do
        -> { { 'title' => 'A Wizard of Earthsea' } }
      end
      let(:error_message) do
        "#{described_class.name} is an abstract class. Define a builder " \
          'class and implement the #criteria_scope_class method.'
      end

      it 'should raise an exception' do
        expect { builder.build(&block) }
          .to raise_error error_class, error_message
      end
    end

    describe 'with a hash' do
      let(:value) { { 'title' => 'A Wizard of Earthsea' } }
      let(:error_message) do
        "#{described_class.name} is an abstract class. Define a builder " \
          'class and implement the #criteria_scope_class method.'
      end

      it 'should raise an exception' do
        expect { builder.build(value) }
          .to raise_error error_class, error_message
      end
    end

    describe 'with a scope' do
      let(:value) do
        scopes = Array.new(3) { build_scope }

        Cuprum::Collections::Scopes::ConjunctionScope.new(scopes:)
      end
      let(:error_message) do
        "#{described_class.name} is an abstract class. Define a builder " \
          'class and implement the #conjunction_scope_class method.'
      end

      it 'should raise an exception' do
        expect { builder.build(value) }
          .to raise_error error_class, error_message
      end
    end
  end

  describe '#build_all_scope' do
    let(:error_class) do
      Cuprum::Collections::Scopes::Building::AbstractBuilderError
    end
    let(:error_message) do
      "#{described_class.name} is an abstract class. Define a builder " \
        'class and implement the #all_scope_class method.'
    end

    it 'should raise an exception' do
      expect { builder.build_all_scope }
        .to raise_error error_class, error_message
    end
  end

  describe '#build_conjunction_scope' do
    let(:error_class) do
      Cuprum::Collections::Scopes::Building::AbstractBuilderError
    end
    let(:error_message) do
      "#{described_class.name} is an abstract class. Define a builder " \
        'class and implement the #conjunction_scope_class method.'
    end

    describe 'with scopes: an empty Array' do
      let(:scopes) { [] }

      it 'should raise an exception' do
        expect { builder.build_conjunction_scope(scopes: []) }
          .to raise_error error_class, error_message
      end
    end

    describe 'with scopes: an Array of Scopes' do
      let(:scopes) { Array.new(3) { build_scope } }

      it 'should raise an exception' do
        expect { builder.build_conjunction_scope(scopes: []) }
          .to raise_error error_class, error_message
      end
    end
  end

  describe '#build_criteria_scope' do
    let(:error_class) do
      Cuprum::Collections::Scopes::Building::AbstractBuilderError
    end
    let(:error_message) do
      "#{described_class.name} is an abstract class. Define a builder " \
        'class and implement the #criteria_scope_class method.'
    end

    describe 'with criteria: an empty Array' do
      let(:criteria) { [] }

      it 'should raise an exception' do
        expect { builder.build_criteria_scope(criteria: []) }
          .to raise_error error_class, error_message
      end
    end

    describe 'with criteria: an Array of criteria' do
      let(:criteria) do
        operators = Cuprum::Collections::Queries::Operators

        [
          [
            'title',
            operators::EQUAL,
            'The Word For World Is Forest'
          ],
          [
            'author',
            operators::EQUAL,
            'Ursula K. LeGuin'
          ],
          [
            'published_at',
            operators::GREATER_THAN,
            '1972-01-01'
          ]
        ]
      end

      it 'should raise an exception' do
        expect { builder.build_criteria_scope(criteria:) }
          .to raise_error error_class, error_message
      end
    end
  end

  describe '#build_disjunction_scope' do
    let(:error_class) do
      Cuprum::Collections::Scopes::Building::AbstractBuilderError
    end
    let(:error_message) do
      "#{described_class.name} is an abstract class. Define a builder " \
        'class and implement the #disjunction_scope_class method.'
    end

    describe 'with scopes: an empty Array' do
      let(:scopes) { [] }

      it 'should raise an exception' do
        expect { builder.build_disjunction_scope(scopes: []) }
          .to raise_error error_class, error_message
      end
    end

    describe 'with scopes: an Array of Scopes' do
      let(:scopes) { Array.new(3) { build_scope } }

      it 'should raise an exception' do
        expect { builder.build_disjunction_scope(scopes: []) }
          .to raise_error error_class, error_message
      end
    end
  end

  describe '#build_none_scope' do
    let(:error_class) do
      Cuprum::Collections::Scopes::Building::AbstractBuilderError
    end
    let(:error_message) do
      "#{described_class.name} is an abstract class. Define a builder " \
        'class and implement the #none_scope_class method.'
    end

    it 'should raise an exception' do
      expect { builder.build_none_scope }
        .to raise_error error_class, error_message
    end
  end
end
