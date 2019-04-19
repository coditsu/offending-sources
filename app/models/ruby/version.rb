# frozen_string_literal: true

module Ruby
  # Ruby gem version representation
  class Version < Base
    self.table_name = :versions

    belongs_to :rubygem,
             class_name: 'Ruby::RubyGem'

    serialize :licenses

    # @return [Ruby::Comparator] object used to compare this gem version with other
    def comparator
      Comparator.new(number)
    end
  end
end
