# frozen_string_literal: true

require 'cuprum/collections/scope'

RSpec.describe Cuprum::Collections::Scope do
  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end
end
