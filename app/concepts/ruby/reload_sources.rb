# frozen_string_literal: true

module Ruby
  # Reloads source files
  class ReloadSources < ApplicationOperation
    step :run

    private

    # Runs appropriate typosquatting
    # @param _accu [Accumulator]
    def run(_accu, **)
      Ruby::GemsTyposquattingDetector::Reload.call({})
      true
    end
  end
end
