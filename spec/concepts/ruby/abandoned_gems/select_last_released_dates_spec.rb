# frozen_string_literal: true

RSpec.describe Ruby::AbandonedGems::SelectLastReleasedDates do
  context 'when one RubyGem requested' do
    subject(:result) { described_class.call(['karafka'])['model'] }

    before do
      FactoryBot.create(:ruby_version, rubygem_id: rubygem.id, built_at: '2018-01-02 12:12:12')
      FactoryBot.create(:ruby_version, rubygem_id: another_gem.id, built_at: '2016-12-12 13:00:01')
    end

    let(:rubygem) { FactoryBot.create(:ruby_gem, name: 'karafka', slug: 'karafka') }
    let(:another_gem) { FactoryBot.create(:ruby_gem, name: 'another_gem', slug: 'another_gem') }

    it 'returns RubyGems list with build_at dates' do
      expect(result).to eq('karafka' => '2018-01-02 12:12:12')
    end
  end

  context 'when many RubyGems requested' do
    subject(:result) { described_class.call(%w[first_awesome_gem second_awesome_gem])['model'] }

    before do
      FactoryBot.create(
        :ruby_version, rubygem_id: first_awesome_gem.id, built_at: '2018-01-02 12:12:12'
      )
      FactoryBot.create(
        :ruby_version, rubygem_id: second_awesome_gem.id, built_at: '2010-10-14 00:11:12'
      )
    end

    let(:first_awesome_gem) do
      FactoryBot.create(:ruby_gem, name: 'first_awesome_gem', slug: 'first_awesome_gem')
    end

    let(:second_awesome_gem) do
      FactoryBot.create(:ruby_gem, name: 'second_awesome_gem', slug: 'second_awesome_gem')
    end

    let(:response) do
      {
        'first_awesome_gem' => '2018-01-02 12:12:12',
        'second_awesome_gem' => '2010-10-14 00:11:12'
      }
    end

    it 'returns RubyGems list with build_at dates' do
      expect(result).to eq response
    end
  end
end
