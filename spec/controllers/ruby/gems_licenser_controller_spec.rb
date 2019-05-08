# frozen_string_literal: true

RSpec.describe Ruby::GemsLicenserController, type: :controller do
  let(:result) { Hash[karafka: '---|||- MIT|||'] }

  specify do
    get :index, params: { data: { 'karafka': '1.2.11' } }

    expect(response).to have_http_status(:ok)
  end

  it 'calls AbandonedGems::SelectLastReleasedDates with correct params' do
    expect(Ruby::GemsLicenser::SelectLicenses)
      .to receive(:call).with(karafka: '1.2.11').and_return('model' => result)

    get :index, params: { data: { 'karafka': '1.2.11' } }
  end
end
