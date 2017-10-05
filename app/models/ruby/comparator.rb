# frozen_string_literal: true

module Ruby
  # Class used to compare different ruby gem versions of the same gem in terms of
  # which one is the more recent one
  class Comparator
    include Comparable
    attr_reader :version

    # Regexp used to extract only the version number out of the full version,
    # excluding .pre stuff
    # @example
    #   '1.0.0.pre.preview1' => '1.0.0'
    VERSION_REGEXP = /([\d\.]*)/

    # Maximum number of levels a gem version can have
    # '0.12.3' #=> 3
    # '0.12.3.34.5' #=> 5
    # '12.1' #=> 2
    # We allow max 10 levels like above
    MAX_VERSION_LEVELS = 10

    # @param version [String] String representing gem version
    def initialize(version)
      @version = calculate_int(
        version.match(VERSION_REGEXP).to_a.first.split('.').map(&:to_i)
      )
    end

    # @param other [OffendingEngine::Harvesters::Ruby::OutdatedGems] other gem object
    def <=>(other)
      version <=> other.version
    end

    private

    # This method build a integer number representing a given gem version. This allows us to
    # easily compare versions like integers, and a bigger number always means, that it is
    # a newer gem release.
    # @param gem_numbers [Array<Integer>] Array with gem number parts
    # @return [Integer] gem version integer representation that allows us to compare them
    def calculate_int(gem_numbers)
      sum = 0
      gem_numbers += Array.new(MAX_VERSION_LEVELS) { 0 }
      gem_numbers.first(MAX_VERSION_LEVELS).each_with_index do |level, index|
        sum += (level + 1) * (10**(MAX_VERSION_LEVELS - index))
      end
      sum
    end
  end
end
