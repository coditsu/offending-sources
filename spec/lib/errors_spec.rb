# frozen_string_literal: true

RSpec.describe Errors do
  it 'has OperationFailure constant' do
    expect(described_class.const_defined?(:OperationFailure)).to be true
  end

  it 'has Base constant' do
    expect(described_class.const_defined?(:Base)).to be true
  end
end
