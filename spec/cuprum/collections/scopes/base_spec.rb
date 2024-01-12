# frozen_string_literal: true

require 'cuprum/collections/scopes/base'

RSpec.describe Cuprum::Collections::Scopes::Base do
  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end

  describe '#type' do
    include_examples 'should define reader', :type, :abstract
  end
end
