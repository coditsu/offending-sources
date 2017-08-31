# frozen_string_literal: true

RSpec.describe KarafkaMonitor do
  subject(:karafka_monitor) { described_class.instance }

  describe '#notice_error' do
    let(:caller_class) { Class.new }
    let(:error) { Class.new(StandardError) }

    it 'expect to notify airbrake' do
      expect(Airbrake).to receive(:notify).with(error)
      karafka_monitor.notice_error(caller_class, error)
    end
  end
end
