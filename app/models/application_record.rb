# frozen_string_literal: true

# Base class for all AR models
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
