# frozen_string_literal: true

require 'cuprum/collections/scopes/composition'
require 'cuprum/collections/scopes/criteria'

module Cuprum::Collections::Scopes::Composition
  # Defines composition behavior for criteria scopes.
  module Criteria
    include Cuprum::Collections::Scopes::Composition

    # (see Cuprum::Collections::Scopes::Composition#and)
    def and(*args, &block)
      criteria =
        if args.first.is_a?(Cuprum::Collections::Scopes::Base)
          return super if args.first.type != :criteria

          args.first.criteria
        else
          self.class.parse(*args, &block)
        end

      with_criteria([*self.criteria, *criteria])
    end
    alias where and
  end
end
