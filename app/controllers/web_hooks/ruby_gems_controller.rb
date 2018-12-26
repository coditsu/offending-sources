# frozen_string_literal: true

module WebHooks
  # HTTP endpoint for accepting ruby gems webhooks
  class RubyGemsController < ApplicationController
    # Sends a given webhook details into a proper topic
    def create
      Ruby::UpdateDb.call(params.permit!)
      head :no_content
    end
  end
end
