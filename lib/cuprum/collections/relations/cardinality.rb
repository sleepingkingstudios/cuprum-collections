# frozen_string_literal: true

require 'cuprum/collections/relations'

module Cuprum::Collections::Relations
  # Methods for resolving a singular or plural relation.
  module Cardinality
    # @return [Boolean] true if the relation is plural; otherwise false.
    def plural?
      @plural
    end

    # @return [Boolean] true if the relation is singular; otherwise false.
    def singular?
      !@plural
    end

    private

    def resolve_plurality(**params) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      if params.key?(:plural) && !params[:plural].nil?
        if params.key?(:singular) && !params[:singular].nil?
          message =
            'ambiguous cardinality: initialized with parameters ' \
            "plural: #{params[:plural].inspect} and singular: " \
            "#{params[:singular].inspect}"

          raise ArgumentError, message
        end

        validate_cardinality(params[:plural], as: 'plural')

        return params[:plural]
      end

      if params.key?(:singular) && !params[:singular].nil?
        validate_cardinality(params[:singular], as: 'singular')

        return !params[:singular]
      end

      true
    end

    def validate_cardinality(value, as:)
      return if value == true || value == false # rubocop:disable Style/MultipleComparison

      raise ArgumentError, "#{as} must be true or false"
    end
  end
end
