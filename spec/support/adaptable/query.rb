# frozen_string_literal: true

require 'support/adaptable'

module Spec::Support::Adaptable
  class Query < Bronze::Basic::Query
    include Bronze::Adaptable::Query

    private

    def convert_native_to_attributes(attributes) = attributes

    def scoped_data
      super.map { |item| convert(item) }
    end
  end
end
