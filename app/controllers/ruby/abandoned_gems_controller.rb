# frozen_string_literal: true

module Ruby
  # Controller that gets hit, when we want to get data for a day, that is not yet snapshotted.
  # This should generate a daily snapshot file, cache it and return.
  class AbandonedGemsController < ApplicationController
    # Returns the date of the last update for requested Gems
    def index
      render json: AbandonedGems::SelectLastReleasedDates
        .call(params[:data])[:model]
        .to_json
    end
  end
end
