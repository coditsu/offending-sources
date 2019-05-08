# frozen_string_literal: true

RSpec.describe Ruby::Comparator do
  subject(:instance) { described_class.new('1.2.0') }

  let(:another_instance) { described_class.new('1.2.3') }

  it 'creates instance with integer version' do
    expect(instance.version).to eq 23_111_111_110
  end

  it 'comparable' do
    expect(instance).to be < another_instance
  end

  describe 'extract only numbers' do
    subject(:prerelease_instance) { described_class.new('1.2.0.pre1') }

    let(:rc_instance) { described_class.new('1.2.0.rc2') }

    specify do
      expect(prerelease_instance).to eq rc_instance
    end
  end
end
