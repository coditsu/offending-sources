# frozen_string_literal: true

module Ruby
  # Controller that gets hit, when we want to get data for a day, that is not yet snapshotted.
  # This should generate a daily snapshot file, cache it and return.
  class OutdatedGemsController < ApplicationController
    # Returns most recent release and prerelease versions of requested gems
    def index
      render json: OutdatedGems::SelectMostRecentVersions
        .call(params[:data])['model']
        .to_json
    end
  end
end
