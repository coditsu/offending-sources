# frozen_string_literal: true

RSpec.describe_current do
  subject(:exporting) { described_class.export_to_csv(file_path, query) }

  let!(:query) { 'some_query' }
  let!(:file_path) { 'file_path' }

  after { exporting }

  describe '.export_to_csv' do
    it 'receive PGPASSWORD variable' do
      expect(described_class).to receive(:system).with(/PGPASSWORD=/)
    end

    describe 'receive system command' do
      let(:flags) { %w[-h -U -p -d -c] }

      specify do
        expect(described_class).to receive(:system).with(/psql/)
      end

      it 'with all needed flags' do
        expect(described_class).to receive(:system).with(/#{flags.join('.*')}/)
      end

      it 'with correct query' do
        expect(described_class).to receive(:system).with(/#{query}/)
      end

      it 'with correct filepath' do
        expect(described_class).to receive(:system).with(/#{file_path}/)
      end
    end
  end
end
