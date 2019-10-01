# frozen_string_literal: true

# Simple hash based accumulator for more complex transactions
class Accumulator < Hash
  # @param initial_values [Hash] all the initial values for the accumulator
  def initialize(initial_values = {})
    merge!(initial_values)
  end

  # @param key [Object] any key under which we might have data
  # @return [Object] anything that was stored under the given key
  # @raise [KeyError] raised when a given key does not exist
  def [](key)
    fetch(key)
  end

  # Overwritten assignment. Will raise an error if key is taken
  # @param key [Object] any object under which we want to store data
  # @param value [Object] anything we want to store
  # @raise [Errors::KeyAlreadyTaken] raised if key already has data
  def []=(key, value)
    raise(Errors::KeyAlreadyTaken, key) if key?(key)

    super
  end
end
