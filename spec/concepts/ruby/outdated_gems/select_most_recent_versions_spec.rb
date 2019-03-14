# frozen_string_literal: true

RSpec.describe Ruby::OutdatedGems::SelectMostRecentVersions do
  subject(:result) { described_class.call([rubygem.name]) }

  let(:rubygem) { FactoryBot.create(:ruby_gem, :karafka) }

  let(:latest_version) do
    {
      rubygem_id: rubygem.id,
      number: '3.4.1',
      latest: true,
      prerelease: false,
      built_at: Time.zone.today
    }
  end

  let(:prerelease_version) do
    {
      rubygem_id: rubygem.id,
      number: '2.5.0',
      latest: false,
      prerelease: true,
      built_at: 1.day.ago
    }
  end

  let(:old_version) do
    {
      rubygem_id: rubygem.id,
      number: '1.0.6',
      latest: false,
      prerelease: false,
      built_at: 1.week.ago
    }
  end

  let(:oldest_version) do
    {
      rubygem_id: rubygem.id,
      number: '0.2.2',
      latest: false,
      prerelease: false,
      built_at: 1.month.ago
    }
  end

  before do
    data.map do |gem_params|
      version = FactoryBot.create(:ruby_version, **gem_params)

      FactoryBot.create(
        :ruby_gem_download,
        rubygem_id: gem_params[:rubygem_id],
        version_id: version.id,
        count: rand(10..2000)
      )
    end
  end

  describe 'latest and prerelease versions exists' do
    let(:data) do
      [
        latest_version,
        prerelease_version,
        old_version,
        oldest_version
      ]
    end

    it 'return both of them' do
      expect(result['model']).to eq('karafka' => ['3.4.1', '2.5.0'])
    end
  end

  describe 'only latest version exists' do
    let(:data) do
      [
        latest_version,
        old_version,
        oldest_version
      ]
    end

    it 'return latest version and nil' do
      expect(result['model']).to eq('karafka' => ['3.4.1', nil])
    end
  end

  describe 'only prerelease version exists' do
    let(:data) do
      [
        prerelease_version,
        old_version,
        oldest_version
      ]
    end

    it 'return latest version and nil' do
      expect(result['model']).to eq('karafka' => [nil, '2.5.0'])
    end
  end
end
