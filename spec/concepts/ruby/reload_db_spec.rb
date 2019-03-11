# frozen_string_literal: true

RSpec.describe Ruby::ReloadDb do
  subject(:reloading) { described_class.call }

  let(:instance) { described_class.new }

  before { allow(described_class).to receive(:new).and_return(instance) }

  after { reloading }

  it 'has DB_USERNAME env variable' do
    expect(instance).to receive(:system).with(/DB_USERNAME/)
  end

  it 'has DB_PASSWORD env variable' do
    expect(instance).to receive(:system).with(/DB_PASSWORD/)
  end

  it 'has DB_HOST env variable' do
    expect(instance).to receive(:system).with(/DB_HOST/)
  end

  it 'has DB_USERNAME env variable' do
    expect(instance).to receive(:system).with(/DB_USERNAME/)
  end

  it 'has DB_PORT env variable' do
    expect(instance).to receive(:system).with(/DB_PORT/)
  end

  it 'has DB_NAME env variable' do
    expect(instance).to receive(:system).with(/DB_NAME/)
  end

  it 'has RAILS_ROOT env variable' do
    expect(instance).to receive(:system).with(/RAILS_ROOT/)
  end
end
