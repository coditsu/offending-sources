# frozen_string_literal: true

RSpec.describe Ruby::OutdatedGemsController, type: :controller do
  let(:result) do
    {
      'karafka': [
        '1.2.11',
        '1.2.0.beta4'
      ]
    }
  end

  specify do
    get :index, params: { data: ['karafka'] }

    expect(response).to have_http_status(:ok)
  end

  it 'calls AbandonedGems::SelectLastReleasedDates with correct params' do
    expect(Ruby::OutdatedGems::SelectMostRecentVersions)
      .to receive(:call).with(['karafka']).and_return('model' => result)

    get :index, params: { data: ['karafka'] }
  end
end
