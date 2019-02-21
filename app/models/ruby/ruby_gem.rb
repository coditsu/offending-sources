# frozen_string_literal: true

module Ruby
  # Ruby gem representation
  class RubyGem < Base
    self.table_name = :rubygems

    has_many :versions,
      class_name: 'Ruby::Version',
      foreign_key: 'rubygem_id'
  end
end
