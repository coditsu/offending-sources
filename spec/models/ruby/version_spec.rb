# frozen_string_literal: true

RSpec.describe_current do
  subject(:version) { described_class.new(number: '1.2.0') }

  it 'has correct table name' do
    expect(described_class.table_name).to eq 'versions'
  end
end
