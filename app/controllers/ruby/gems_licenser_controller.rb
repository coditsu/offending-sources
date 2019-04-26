# frozen_string_literal: true

module Ruby
  # Controller for handling processing of requests for gems licenses data
  class GemsLicenserController < ApplicationController
    # Returns the licenses for requested gems versions
    def index
      render json: GemsLicenser::SelectLicenses
        .call(params.require(:data).permit!.to_h)['model']
        .to_json
    end
  end
end
