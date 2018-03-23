# frozen_string_literal: true

module Ruby
  # Consumer that reacts to new webhooks received from ruby gems
  class UpdateDbConsumer < ApplicationConsumer
    # Updates gem DB details and current file reference
    def consume
      UpdateDb.call(params[:value])
    end
  end
end
