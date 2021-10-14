# frozen_string_literal: true

require 'cuprum/collections'

RSpec.describe Cuprum::Collections do
  describe '::VERSION' do
    let(:version_pattern) do
      /\A\d+\.\d+\.\d+(\.(alpha|beta|rc))?(\.\d+)?\z/
    end

    include_examples 'should define constant', :VERSION, -> { be_a String }

    it { expect(described_class::VERSION).to match(version_pattern) }
  end

  describe '.gem_path' do
    let(:expected) do
      sep = File::SEPARATOR

      __dir__.sub(/#{sep}spec#{sep}cuprum#{sep}?\z/, '')
    end

    include_examples 'should define class reader',
      :gem_path,
      -> { be == expected }
  end

  describe '.version' do
    include_examples 'should have class reader',
      :version,
      described_class::VERSION
  end
end
