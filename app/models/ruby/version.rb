# frozen_string_literal: true

module Ruby
  # Ruby gem version representation
  class Version < Base
    self.table_name = :versions

    serialize :licenses
  end
end
