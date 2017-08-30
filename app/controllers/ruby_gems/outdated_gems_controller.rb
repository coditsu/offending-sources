# frozen_string_literal: true

module RubyGems
  class OutdatedGemsController < ApplicationController
    def show
      send_file OutdatedGems::Reload.call(
        snapshotted_at: Date.parse(params[:id])
      )['location']
    end
  end
end
