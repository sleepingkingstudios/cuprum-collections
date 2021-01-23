# frozen_string_literal: true

require 'cuprum/collections/errors'
require 'cuprum/collections/queries'

module Cuprum::Collections::Errors
  # An error returned when a query attempts to filter by an unknown operator.
  class UnknownOperator < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.collections.errors.unknown_operator'

    # @param operator [String, Symbol] The unknown operator.
    def initialize(operator:)
      @operator = operator

      super(message: generate_message)
    end

    # @return [String, Symbol] the unknown operator.
    attr_reader :operator

    def as_json
      {
        'data'    => {
          'corrections' => corrections,
          'operator'    => operator
        },
        'message' => message,
        'type'    => type
      }
    end

    # @return [Array<String>] Suggested possible values for the operator.
    def corrections
      @corrections ||=
        DidYouMean::SpellChecker
        .new(dictionary: Cuprum::Collections::Queries::VALID_OPERATORS.to_a)
        .correct(operator)
    end

    # @return [String] short string used to identify the type of error.
    def type
      TYPE
    end

    private

    def generate_message
      message = "unknown operator #{operator.inspect}"

      return message if corrections.empty?

      "#{message} - did you mean #{suggestion}?"
    end

    def suggestion
      tools.ary.humanize_list(
        corrections.map(&:inspect),
        last_separator: ', or '
      )
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
