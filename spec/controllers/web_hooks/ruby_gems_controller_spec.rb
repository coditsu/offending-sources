# frozen_string_literal: true

RSpec.describe WebHooks::RubyGemsController, type: :controller do
  specify do
    allow(Ruby::UpdateDb).to receive(:call)
    get :create

    expect(response).to have_http_status(:no_content)
  end

  it 'calls AbandonedGems::SelectLastReleasedDates with correct params' do
    expect(Ruby::UpdateDb).to receive(:call)

    get :create
  end
end
