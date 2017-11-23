# frozen_string_literal: true

# Model containing settings logic for this app
class Settings < Settingslogic
  source Rails.root.join('config', 'settings.yml')
  namespace Rails.env.to_s
end
