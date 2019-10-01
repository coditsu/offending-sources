# frozen_string_literal: true

RSpec.describe_current do
  describe 'when one RubyGem requested' do
    subject(:result) { described_class.call(rubygem.name => '1.0.0')[:model] }

    let(:rubygem) { FactoryBot.create(:ruby_gem, :karafka) }

    before do
      FactoryBot.create(
        :ruby_version,
        rubygem_id: rubygem.id,
        built_at: '2018-01-02 12:12:12',
        licenses: licenses
      )
    end

    context 'with one license' do
      let(:licenses) { ['MIT'] }

      it 'returns formatted lincenses' do
        expect(result).to eq('karafka' => '---|||- MIT|||')
      end
    end

    context 'with two licenses' do
      let(:licenses) { ['MIT', '(c) Koditsu'] }

      it 'returns formatted lincenses' do
        expect(result).to eq('karafka' => '---|||- MIT|||- "(c) Koditsu"|||')
      end
    end
  end

  describe 'when many RubyGems requested' do
    subject(:result) { described_class.call(requested_gems)[:model] }

    let(:requested_gems) { Hash[rubygem.name => '1.0.0', another_rubygem.name => '2.3.1'] }

    let(:rubygem) { FactoryBot.create(:ruby_gem, :karafka) }
    let(:another_rubygem) { FactoryBot.create(:ruby_gem, :another_gem) }

    before do
      FactoryBot.create(
        :ruby_version,
        rubygem_id: rubygem.id,
        built_at: '2018-01-02 12:12:12',
        licenses: karafka_licenses
      )

      FactoryBot.create(
        :ruby_version,
        rubygem_id: another_rubygem.id,
        built_at: '2018-01-02 12:12:12',
        licenses: another_licenses
      )
    end

    context 'with one license' do
      let(:karafka_licenses) { ['MIT'] }
      let(:another_licenses) { ['Apache-2.0'] }

      let(:response) do
        { 'another_gem' => '---|||- Apache-2.0|||', 'karafka' => '---|||- MIT|||' }
      end

      it 'returns formatted lincenses' do
        expect(result).to eq response
      end
    end

    context 'with two licenses' do
      let(:karafka_licenses) { ['MIT', '(c) Koditsu'] }
      let(:another_licenses) { ['Apache-2.0', '(c) Amazing Company'] }

      let(:response) do
        {
          'another_gem' => '---|||- Apache-2.0|||- "(c) Amazing Company"|||',
          'karafka' => '---|||- MIT|||- "(c) Koditsu"|||'
        }
      end

      it 'returns formatted lincenses' do
        expect(result).to eq response
      end
    end
  end
end
