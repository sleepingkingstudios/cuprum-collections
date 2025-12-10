# frozen_string_literal: true

require 'support/adaptable'

module Spec::Support::Adaptable
  class Query < Cuprum::Collections::Basic::Query
    include Cuprum::Collections::Adaptable::Query

    private

    def convert_native_to_attributes(attributes) = attributes

    def scoped_data
      super.map { |item| convert(item) }
    end
  end
end
