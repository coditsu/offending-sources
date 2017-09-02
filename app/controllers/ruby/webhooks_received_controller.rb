# frozen_string_literal: true

module Ruby
  # Controller that reacts to new webhooks received from ruby gems
  class WebhooksReceivedController < KarafkaController
    def perform
      Update.call(params)
    end
  end
end
