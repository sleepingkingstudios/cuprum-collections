# frozen_string_literal: true

require 'cuprum/collections/relations'

module Cuprum::Collections::Relations
  # Methods for defining a scope for a relation.
  module Scope
    # @overload initialize(scope: nil, **)
    #   @param scope [Cuprum::Collections::Scopes::Base, Hash, Proc, nil] the
    #     configured scope for the relation.
    def initialize(scope: nil, **parameters)
      super(**parameters)

      @scope = apply_scope(default_scope, scope)
    end

    # @return [Cuprum::Collections::Scopes::Base] the configured scope for the
    #   relation.
    attr_reader :scope

    # @overload with_scope(scope)
    #   Copies the relation and applies the scope to the copy.
    #
    #   @param scope [Cuprum::Collections::Scopes::Base, Hash, Proc] the scope
    #     to apply. The scope will be combined with the existing scope on the
    #     relation, if any.
    #
    #   @return [Cuprum::Collections::Relations::Scope] the copy of the
    #     relation.
    #
    # @overload with_scope(&block)
    #   Copies the relation and applies the scope to the copy.
    #
    #   @yieldparam query
    #     [Cuprum::Collections::Scopes::Criteria::Parser::BlockParser] the
    #     receiver for the scope block.
    #   @yieldreturn [Hash] the query hash for the scope.
    #
    #   @return [Cuprum::Collections::Relations::Scope] the copy of the
    #     relation.
    def with_scope(value = nil, &block)
      dup.tap { |copy| copy.scope = apply_scope(scope, value || block) }
    end

    protected

    attr_writer :scope

    private

    def apply_scope(current_scope, scope)
      if scope.is_a?(Proc)
        current_scope.and(&scope)
      elsif scope
        current_scope.and(scope)
      else
        current_scope
      end
    end

    def default_scope
      Cuprum::Collections::Scopes::AllScope.new
    end
  end
end
