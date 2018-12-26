# frozen_string_literal: true

module Webhooks
  # HTTP endpoint for accepting ruby gems webhooks
  class RubyGemsController < ApplicationController
    # Sends a given webhook details into a proper topic
    def create
      UpdateDb.call(params[:value])
      RubyGemsResponder.call(params.permit!)
      head :no_content
    end
  end
end
