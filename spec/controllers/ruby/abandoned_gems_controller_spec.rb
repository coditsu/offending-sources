# frozen_string_literal: true

RSpec.describe Ruby::AbandonedGemsController, type: :controller do
  let(:result) { Hash[karafka: '2019-02-05T00:00:00.000Z'] }

  specify do
    get :index, params: { data: ['karafka'] }

    expect(response).to have_http_status(:ok)
  end

  it 'calls AbandonedGems::SelectLastReleasedDates with correct params' do
    expect(Ruby::AbandonedGems::SelectLastReleasedDates)
      .to receive(:call).with(['karafka']).and_return('model' => result)

    get :index, params: { data: ['karafka'] }
  end
end
