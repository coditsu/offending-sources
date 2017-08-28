# frozen_string_literal: true

# Namespace for app errors
module Errors
  # Base app error
  Base = Class.new(StandardError)
  # Raised when we have a non-fail operation and it fails
  OperationFailure = Class.new(Base)
end
