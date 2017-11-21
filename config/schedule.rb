# frozen_string_literal: true

every :day, at: '0am', roles: %i[web] do
  rake 'app:reload_sources'
end
