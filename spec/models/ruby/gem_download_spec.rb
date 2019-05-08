# frozen_string_literal: true

RSpec.describe Ruby::GemDownload do
  it 'has correct table name' do
    expect(described_class.table_name).to eq 'gem_downloads'
  end
end
