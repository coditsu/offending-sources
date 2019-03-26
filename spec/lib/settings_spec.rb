# frozen_string_literal: true

RSpec.describe Settings do
  it '.source' do
    expect(described_class.source).to be_a Pathname
  end

  it '.namespace' do
    expect(described_class.namespace).to eq 'test'
  end
end
