# frozen_string_literal: true

module Ruby
  # Controller that reacts to new webhooks received from ruby gems
  class UpdateDbController < KarafkaController
    # Updates gem DB details and current file reference
    def consume
      UpdateDb.call(params)
    end
  end
end