# frozen_string_literal: true

module Ruby
  # Ruby gem representation
  class RubyGem < Base
    self.table_name = :rubygems

    has_many :versions,
             dependent: :delete_all,
             inverse_of: :rubygem,
             class_name: 'Ruby::Version',
             foreign_key: 'rubygem_id'
  end
end
