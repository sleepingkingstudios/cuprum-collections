# frozen_string_literal: true

require 'cuprum/collections/scopes/composition'
require 'cuprum/collections/scopes/criteria'

module Cuprum::Collections::Scopes::Composition
  # Defines composition behavior for criteria scopes.
  module Criteria
    include Cuprum::Collections::Scopes::Composition

    # (see Cuprum::Collections::Scopes::Composition#and)
    def and(*args, &block)
      return and_criteria_scope(args.first) if criteria_scope?(args.first)

      return super if scope?(args.first)

      with_criteria([*criteria, *self.class.parse(*args, &block)])
    end
    alias where and

    private

    def and_criteria_scope(scope)
      with_criteria([*criteria, *scope.criteria])
    end
  end
end
