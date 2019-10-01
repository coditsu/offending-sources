# frozen_string_literal: true

module Ruby
  # Controller that handles processing requests related to outdated gems analysis
  class OutdatedGemsController < ApplicationController
    # Returns most recent release and prerelease versions of requested gems
    def index
      render json: OutdatedGems::SelectMostRecentVersions
        .call(params[:data])[:model]
        .to_json
    end
  end
end
