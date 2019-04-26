# frozen_string_literal: true

every 30.minutes, roles: %i[web] do
  rake 'app:reload_sources'
end
