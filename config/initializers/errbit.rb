# frozen_string_literal: true

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

Airbrake.configure do |config|
  config.environment = Rails.env
  config.host        = Settings.errbit.host
  config.project_id  = Settings.errbit.project_id
  config.project_key = Settings.errbit.project_key
  config.ignore_environments = %w[development test]
end

module Patches
  module Airbrake
    # Patches for Airbrake SyncSender
    module SyncSender
      def build_https(uri)
        super.tap do |req|
          req.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      end
    end
  end
end

Airbrake::SyncSender.prepend(::Patches::Airbrake::SyncSender)
