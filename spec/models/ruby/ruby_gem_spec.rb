# frozen_string_literal: true

RSpec.describe Ruby::RubyGem do
  it 'has correct table name' do
    expect(described_class.table_name).to eq 'rubygems'
  end
end
