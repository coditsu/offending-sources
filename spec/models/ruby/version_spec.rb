# frozen_string_literal: true

RSpec.describe Ruby::Version do
  subject(:version) { described_class.new(number: '1.2.0') }

  it 'has correct table name' do
    expect(described_class.table_name).to eq 'versions'
  end

  it '#comparator' do
    expect(Ruby::Comparator).to receive(:new).with('1.2.0')
    version.comparator
  end
end
