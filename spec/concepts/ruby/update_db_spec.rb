# frozen_string_literal: true

RSpec.describe_current do
  let(:ruby_gem) { Ruby::RubyGem.first }
  let(:ruby_version) { Ruby::Version.first }
  let(:gem_download) { Ruby::GemDownload.first }

  context "when gem doesn't exist in the database" do
    it 'creates new RubyGem reference' do
      described_class.call(name: 'rails')
      expect(ruby_gem.name).to eq 'rails'
    end

    describe 'creates new RubyGem reference' do
      it 'with corrent version' do
        described_class.call(name: 'rails', version: '6.0.0')
        expect(ruby_version.number).to eq '6.0.0'
      end

      it 'with corrent licenses' do
        described_class.call(name: 'rails', licenses: 'MIT')
        expect(ruby_version.licenses).to eq 'MIT'
      end
    end

    describe 'creates new GemDownload reference' do
      it 'with corrent version_id' do
        described_class.call(name: 'rails', version: '6.0.0')
        expect(gem_download.version_id).to eq ruby_version.id
      end

      it 'with corrent rubygem_id' do
        described_class.call(name: 'rails', licenses: 'MIT')
        expect(gem_download.rubygem_id).to eq ruby_gem.id
      end

      it 'with corrent version downloads' do
        described_class.call(name: 'rails', version_downloads: 50)
        expect(gem_download.count).to eq 50
      end
    end

    context 'when prerelease' do
      it "doesn't mark relese as latest" do
        described_class.call(name: 'rails', version: '6.0.0.rc1')
        expect(ruby_version.latest).to be false
      end
    end

    context 'when not prerelease' do
      it 'mark relese as latest' do
        described_class.call(name: 'rails', version: '6.0.0')
        expect(ruby_version.latest).to be true
      end

      describe 'mark another versions as not latest' do
        let(:rails_gem) { FactoryBot.create(:ruby_gem, :karafka) }
        let(:previous_version) do
          FactoryBot.create(
            :ruby_version,
            rubygem_id: rails_gem.id,
            latest: true,
            number: '5.2.2'
          )
        end

        specify do
          expect { described_class.call(name: 'karafka', version: '6.0.0') }
            .to change { previous_version.reload.latest }.from(true).to(false)
        end
      end
    end
  end
end
