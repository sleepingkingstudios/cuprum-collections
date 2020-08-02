# frozen_string_literal: true

require 'cuprum/collections/base'

RSpec.describe Cuprum::Collections::Base do
  subject(:collection) { described_class.new }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end
end
