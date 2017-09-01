# frozen_string_literal: true

module RubyGems
  # Ruby gem version representation
  class Version < Base
    self.table_name = :versions

    serialize :licenses
  end
end
