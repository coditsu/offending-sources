# frozen_string_literal: true

module Ruby
  # Reloads source files
  class ReloadSources < ApplicationOperation
    step lambda { |_ctx, **|
      Ruby::GemsTyposquattingDetector::Reload.call({})
    }
  end
end
