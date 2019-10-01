# frozen_string_literal: true

RSpec.describe_current do
  subject(:accu) { described_class.new(a: 1) }

  describe '[]' do
    context 'when we want to retrieve a non existing value' do
      it { expect { accu[:b] }.to raise_error(KeyError, /key not found: :b/) }
    end

    context 'when we retrieve an existing value' do
      it { expect(accu[:a]).to eq(1) }
    end
  end

  describe '[]=' do
    context 'when we want to assign a non existing value' do
      it { expect { accu[:b] = 1 }.not_to raise_error }
      it { expect(accu[:b] = 1).to eq(1) }
    end

    context 'when we want to assign an existing value' do
      it { expect { accu[:a] = 1 }.to raise_error(Errors::KeyAlreadyTaken) }
    end
  end
end
