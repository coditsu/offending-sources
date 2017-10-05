# frozen_string_literal: true

module Ruby
  # Ruby gem version representation
  class Version < Base
    self.table_name = :versions

    serialize :licenses

    # @return [Ruby::Comparator] object used to compare this gem version with other
    def comparator
      Comparator.new(number)
    end
  end
end
