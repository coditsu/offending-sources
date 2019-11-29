# frozen_string_literal: true

RSpec.describe_current do
  subject(:reloading) { described_class.call }

  let(:instance) { described_class.new }
  let(:command) { Rails.root.join('bin/rubygems/reload.sh download') }

  before { allow(described_class).to receive(:new).and_return(instance) }

  after { reloading }

  it 'calls reload.sh' do
    expect(instance).to receive(:system).with(/#{command}/)
  end

  describe 'calls reload.sh with necessary ENV variable' do
    it 'DB_USERNAME' do
      expect(instance).to receive(:system).with(/DB_USERNAME/)
    end

    it 'DB_PASSWORD' do
      expect(instance).to receive(:system).with(/DB_PASSWORD/)
    end

    it 'DB_HOST' do
      expect(instance).to receive(:system).with(/DB_HOST/)
    end

    it 'has DB_PORT' do
      expect(instance).to receive(:system).with(/DB_PORT/)
    end

    it 'has DB_NAME' do
      expect(instance).to receive(:system).with(/DB_NAME/)
    end

    it 'has RAILS_ROOT' do
      expect(instance).to receive(:system).with(/RAILS_ROOT/)
    end
  end
end
