# frozen_string_literal: true

# Namespace for all the things related to incoming webhooks data
module WebHooks
  # HTTP endpoint for accepting ruby gems webhooks
  class RubyGemsController < ApplicationController
    # Sends a given web-hook details into a proper topic
    def create
      Ruby::UpdateDb.call(params.permit!)
      head :no_content
    end
  end
end
