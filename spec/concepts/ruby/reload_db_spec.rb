# frozen_string_literal: true

RSpec.describe Ruby::ReloadDb do
  it 'has DB_USERNAME env variable' do
    expect_any_instance_of(Kernel).to receive(:system).with(/DB_USERNAME/)
    described_class.call
  end

  it 'has DB_PASSWORD env variable' do
    expect_any_instance_of(Kernel).to receive(:system).with(/DB_PASSWORD/)
    described_class.call
  end

  it 'has DB_HOST env variable' do
    expect_any_instance_of(Kernel).to receive(:system).with(/DB_HOST/)
    described_class.call
  end

  it 'has DB_USERNAME env variable' do
    expect_any_instance_of(Kernel).to receive(:system).with(/DB_USERNAME/)
    described_class.call
  end

  it 'has DB_PORT env variable' do
    expect_any_instance_of(Kernel).to receive(:system).with(/DB_PORT/)
    described_class.call
  end

  it 'has DB_NAME env variable' do
    expect_any_instance_of(Kernel).to receive(:system).with(/DB_NAME/)
    described_class.call
  end

  it 'has RAILS_ROOT env variable' do
    expect_any_instance_of(Kernel).to receive(:system).with(/RAILS_ROOT/)
    described_class.call
  end
end
