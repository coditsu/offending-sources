# frozen_string_literal: true

RSpec.describe_current do
  let(:tmp_dir) { Rails.root.join('tmp/spec') }
  let(:filename) { 'current.csv' }
  let(:full_path) { tmp_dir.join(filename) }

  let(:operation_with_stubbed_sources_path) do
    Class.new(described_class) do
      def sources_path
        Rails.root.join('tmp/spec')
      end
    end
  end

  after do
    FileUtils.remove_dir(tmp_dir) if tmp_dir.exist?
  end

  it 'creates csv file with correct name' do
    operation_with_stubbed_sources_path.call
    expect(full_path).to exist
  end

  it 'creates folder if not exists' do
    operation_with_stubbed_sources_path.call
    expect(tmp_dir).to exist
  end

  context 'when previous file exists' do
    before do
      FileUtils.mkdir tmp_dir
      FileUtils.touch tmp_dir.join(filename)
    end

    let!(:previous_file_created_at) { File.ctime full_path }

    it 'removes previous file' do
      operation_with_stubbed_sources_path.call
      expect(previous_file_created_at).not_to eq File.ctime(full_path)
    end
  end

  it 'calls Ruby::Base#export_to_csv method with right args' do
    expect(Ruby::Base).to receive(:export_to_csv)
      .with(an_instance_of(String), described_class::QUERY)
    operation_with_stubbed_sources_path.call
  end
end
