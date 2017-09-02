# frozen_string_literal: true

module Ruby
  # Controller that gets hit, when we want to get data for a day, that is not yet snapshotted.
  # This should generate a daily snapshot file, cache it and return.
  class OutdatedGemsController < ApplicationController
    # Generates and returns a csv with data for outdated gems validator
    def show
      send_file OutdatedGems::Reload.call(day: Date.parse(params[:id]))['model']
    end
  end
end
