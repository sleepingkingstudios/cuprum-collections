# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/collections/rspec/deferred/scopes'

module Cuprum::Collections::RSpec::Deferred::Scopes
  # Deferred examples for asserting on scope parsing.
  module ParserExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should parse Scope criteria' do
      describe 'with a block' do
        include_deferred 'should parse Scope criteria from a block'
      end

      describe 'with a hash' do
        include_deferred 'should parse Scope criteria from a Hash'
      end

      describe 'with a hash and a block' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          lambda do |scope|
            { 'author' => scope.one_of('J.R.R. Tolkien', 'Ursula K. LeGuin') }
          end
        end
        let(:value) do
          { 'category' => 'Science Fiction and Fantasy' }
        end
        let(:expected) do
          [
            [
              'category',
              operators::EQUAL,
              'Science Fiction and Fantasy'
            ],
            [
              'author',
              operators::ONE_OF,
              ['J.R.R. Tolkien', 'Ursula K. LeGuin']
            ]
          ]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(value, &block)).to be == expected
        end
      end
    end

    deferred_examples 'should parse Scope criteria from a Hash' do
      describe 'with nil' do
        let(:error_message) do
          'value must be a Hash with String or Symbol keys'
        end

        it 'should raise an exception' do
          expect { parse_criteria(nil) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with an Object' do
        let(:error_message) do
          'value must be a Hash with String or Symbol keys'
        end

        it 'should raise an exception' do
          expect { parse_criteria(Object.new.freeze) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a Hash with invalid keys' do
        let(:error_message) do
          'value must be a Hash with String or Symbol keys'
        end
        let(:value)         { { nil => 'invalid' } }

        it 'should raise an exception' do
          expect { parse_criteria(value) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with an empty Hash' do
        let(:value) { {} }

        it { expect(parse_criteria(value)).to be == [] }
      end

      describe 'with a Hash with one key' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:value) do
          { 'title' => 'A Wizard of Earthsea' }
        end
        let(:expected) do
          [['title', operators::EQUAL, 'A Wizard of Earthsea']]
        end

        it { expect(parse_criteria(value)).to be == expected }
      end

      describe 'with a Hash with many String keys' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:value) do
          {
            'title'  => 'A Wizard of Earthsea',
            'author' => 'Ursula K. LeGuin',
            'series' => 'Earthsea'
          }
        end
        let(:expected) do
          [
            ['title', operators::EQUAL, 'A Wizard of Earthsea'],
            ['author', operators::EQUAL, 'Ursula K. LeGuin'],
            ['series', operators::EQUAL, 'Earthsea']
          ]
        end

        it { expect(parse_criteria(value)).to be == expected }
      end

      describe 'with a Hash with many Symbol keys' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:value) do
          {
            title:  'A Wizard of Earthsea',
            author: 'Ursula K. LeGuin',
            series: 'Earthsea'
          }
        end
        let(:expected) do
          [
            ['title', operators::EQUAL, 'A Wizard of Earthsea'],
            ['author', operators::EQUAL, 'Ursula K. LeGuin'],
            ['series', operators::EQUAL, 'Earthsea']
          ]
        end

        it { expect(parse_criteria(value)).to be == expected }
      end
    end

    deferred_examples 'should parse Scope criteria from a block' do
      describe 'without a block' do
        let(:error_message) { 'no block given' }

        it 'should raise an exception' do
          expect { parse_criteria }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a block returning nil' do
        let(:error_message) do
          'value must be a Hash with String or Symbol keys'
        end

        it 'should raise an exception' do
          expect { parse_criteria { nil } }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a block returning an Object' do
        let(:error_message) do
          'value must be a Hash with String or Symbol keys'
        end

        it 'should raise an exception' do
          expect { parse_criteria { Object.new.freeze } }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a block returning a Hash with invalid keys' do
        let(:error_message) do
          'value must be a Hash with String or Symbol keys'
        end
        let(:block)         { -> { { nil => 'invalid' } } }

        it 'should raise an exception' do
          expect { parse_criteria(&block) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a block returning an empty Hash' do
        let(:block) { -> { {} } }

        it { expect(parse_criteria(&block)).to be == [] }
      end

      describe 'with a block returning a Hash with one key' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          -> { { 'title' => 'A Wizard of Earthsea' } }
        end
        let(:expected) do
          [['title', operators::EQUAL, 'A Wizard of Earthsea']]
        end

        it { expect(parse_criteria(&block)).to be == expected }
      end

      describe 'with a Hash with many String keys' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          lambda do
            {
              'title'  => 'A Wizard of Earthsea',
              'author' => 'Ursula K. LeGuin',
              'series' => 'Earthsea'
            }
          end
        end
        let(:expected) do
          [
            ['title', operators::EQUAL, 'A Wizard of Earthsea'],
            ['author', operators::EQUAL, 'Ursula K. LeGuin'],
            ['series', operators::EQUAL, 'Earthsea']
          ]
        end

        it { expect(parse_criteria(&block)).to be == expected }
      end

      describe 'with a Hash with many Symbol keys' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          lambda do
            {
              title:  'A Wizard of Earthsea',
              author: 'Ursula K. LeGuin',
              series: 'Earthsea'
            }
          end
        end
        let(:expected) do
          [
            ['title', operators::EQUAL, 'A Wizard of Earthsea'],
            ['author', operators::EQUAL, 'Ursula K. LeGuin'],
            ['series', operators::EQUAL, 'Earthsea']
          ]
        end

        it { expect(parse_criteria(&block)).to be == expected }
      end

      describe 'with a Hash with an "eq" operator' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          ->(scope) { { 'title' => scope.eq('A Wizard of Earthsea') } }
        end
        let(:expected) do
          [['title', operators::EQUAL, 'A Wizard of Earthsea']]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with an "equal" operator' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          ->(scope) { { 'title' => scope.equal('A Wizard of Earthsea') } }
        end
        let(:expected) do
          [['title', operators::EQUAL, 'A Wizard of Earthsea']]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with an "equals" operator' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          ->(scope) { { 'title' => scope.equals('A Wizard of Earthsea') } }
        end
        let(:expected) do
          [['title', operators::EQUAL, 'A Wizard of Earthsea']]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "greater_than" operator' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          ->(scope) { { 'published_at' => scope.greater_than('1970-01-01') } }
        end
        let(:expected) do
          [['published_at', operators::GREATER_THAN, '1970-01-01']]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "greater_than_or_equal_to" operator' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          lambda do |scope|
            { 'published_at' => scope.greater_than_or_equal_to('1970-01-01') }
          end
        end
        let(:expected) do
          [
            [
              'published_at',
              operators::GREATER_THAN_OR_EQUAL_TO,
              '1970-01-01'
            ]
          ]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "gt" operator' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          ->(scope) { { 'published_at' => scope.gt('1970-01-01') } }
        end
        let(:expected) do
          [['published_at', operators::GREATER_THAN, '1970-01-01']]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "gte" operator' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          ->(scope) { { 'published_at' => scope.gte('1970-01-01') } }
        end
        let(:expected) do
          [
            [
              'published_at',
              operators::GREATER_THAN_OR_EQUAL_TO,
              '1970-01-01'
            ]
          ]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "less_than" operator' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          ->(scope) { { 'published_at' => scope.less_than('1970-01-01') } }
        end
        let(:expected) do
          [['published_at', operators::LESS_THAN, '1970-01-01']]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "less_than_or_equal_to" operator' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          lambda do |scope|
            { 'published_at' => scope.less_than_or_equal_to('1970-01-01') }
          end
        end
        let(:expected) do
          [['published_at', operators::LESS_THAN_OR_EQUAL_TO, '1970-01-01']]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "lt" operator' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          ->(scope) { { 'published_at' => scope.lt('1970-01-01') } }
        end
        let(:expected) do
          [['published_at', operators::LESS_THAN, '1970-01-01']]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "lte" operator' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          ->(scope) { { 'published_at' => scope.lte('1970-01-01') } }
        end
        let(:expected) do
          [['published_at', operators::LESS_THAN_OR_EQUAL_TO, '1970-01-01']]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "ne" operator' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          ->(scope) { { 'series' => scope.ne('Earthsea') } }
        end
        let(:expected) do
          [['series', operators::NOT_EQUAL, 'Earthsea']]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "not_equal" operator' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          ->(scope) { { 'series' => scope.not_equal('Earthsea') } }
        end
        let(:expected) do
          [['series', operators::NOT_EQUAL, 'Earthsea']]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "not_null" operator' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          ->(scope) { { 'series' => scope.not_null } }
        end
        let(:expected) do
          [['series', operators::NOT_NULL, nil]]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "not_one_of" operator and an Array' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          lambda do |scope|
            {
              'series' => scope.not_one_of(
                ['Earthsea', 'The Lord of the Rings']
              )
            }
          end
        end
        let(:expected) do
          [
            [
              'series',
              operators::NOT_ONE_OF,
              ['Earthsea', 'The Lord of the Rings']
            ]
          ]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "not_one_of" operator and a Set' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          lambda do |scope|
            {
              'series' => scope.not_one_of(
                Set.new(['Earthsea', 'The Lord of the Rings'])
              )
            }
          end
        end
        let(:expected) do
          [
            [
              'series',
              operators::NOT_ONE_OF,
              ['Earthsea', 'The Lord of the Rings']
            ]
          ]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "not_one_of" operator and values' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          lambda do |scope|
            {
              'series' => scope.not_one_of(
                'Earthsea',
                'The Lord of the Rings'
              )
            }
          end
        end
        let(:expected) do
          [
            [
              'series',
              operators::NOT_ONE_OF,
              ['Earthsea', 'The Lord of the Rings']
            ]
          ]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "null" operator' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          ->(scope) { { 'series' => scope.null } }
        end
        let(:expected) do
          [['series', operators::NULL, nil]]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "one_of" operator and an Array' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          lambda do |scope|
            {
              'series' => scope.one_of(
                ['Earthsea', 'The Lord of the Rings']
              )
            }
          end
        end
        let(:expected) do
          [
            [
              'series',
              operators::ONE_OF,
              ['Earthsea', 'The Lord of the Rings']
            ]
          ]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "one_of" operator and a Set' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          lambda do |scope|
            {
              'series' => scope.one_of(
                Set.new(['Earthsea', 'The Lord of the Rings'])
              )
            }
          end
        end
        let(:expected) do
          [
            [
              'series',
              operators::ONE_OF,
              ['Earthsea', 'The Lord of the Rings']
            ]
          ]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with a "one_of" operator and values' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          lambda do |scope|
            {
              'series' => scope.one_of(
                'Earthsea',
                'The Lord of the Rings'
              )
            }
          end
        end
        let(:expected) do
          [
            [
              'series',
              operators::ONE_OF,
              ['Earthsea', 'The Lord of the Rings']
            ]
          ]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with an unknown operator' do
        let(:error_class) do
          Cuprum::Collections::Queries::UnknownOperatorException
        end
        let(:error_message) do
          'unknown operator "random"'
        end
        let(:block) do
          -> { { 'genre' => random('Science Fiction', 'Fantasy') } }
        end

        it 'should raise an exception' do
          expect { parse_criteria(&block) }
            .to raise_error error_class, error_message
        end

        it 'should preserve the original exception', :aggregate_failures do
          parse_criteria(&block)
        rescue error_class => exception
          expect(exception.cause).to be_a NameError
          expect(exception.name).to be == :random
        end
      end

      describe 'with a Hash with multiple operators' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          lambda do |scope|
            {
              'published_at' => scope.greater_than('1970-01-01'),
              'series'       => scope.one_of(
                ['Earthsea', 'The Lord of the Rings']
              ),
              'title'        => scope.not_equal('The Tombs of Atuan')
            }
          end
        end
        let(:expected) do
          [
            [
              'published_at',
              operators::GREATER_THAN,
              '1970-01-01'
            ],
            [
              'series',
              operators::ONE_OF,
              ['Earthsea', 'The Lord of the Rings']
            ],
            [
              'title',
              operators::NOT_EQUAL,
              'The Tombs of Atuan'
            ]
          ]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end

      describe 'with a Hash with mixed keys and operators' do
        let(:operators) { Cuprum::Collections::Queries::Operators }
        let(:block) do
          lambda do |scope|
            {
              'author'   => scope.one_of(
                'J.R.R. Tolkien',
                'Ursula K. LeGuin'
              ),
              'category' => 'Science Fiction and Fantasy'
            }
          end
        end
        let(:expected) do
          [
            [
              'author',
              operators::ONE_OF,
              ['J.R.R. Tolkien', 'Ursula K. LeGuin']
            ],
            [
              'category',
              operators::EQUAL,
              'Science Fiction and Fantasy'
            ]
          ]
        end

        it 'should parse the criteria' do
          expect(parse_criteria(&block)).to be == expected
        end
      end
    end
  end
end
