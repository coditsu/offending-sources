# frozen_string_literal: true

RSpec.describe Ruby::ReloadSources do
  it 'calls Ruby::GemsTyposquattingDetector::Reload' do
    expect(Ruby::GemsTyposquattingDetector::Reload).to receive(:call).with({}).once
    described_class.call
  end
end
