# frozen_string_literal: true

require 'cuprum/collections'

require 'support/adaptable'
require 'support/adaptable/query'

module Spec::Support::Adaptable
  class Collection < Cuprum::Collections::Basic::Collection
    include Cuprum::Collections::Adaptable::Collection

    def query
      Spec::Support::Adaptable::Query.new(data, adapter:, scope:)
    end
  end
end
