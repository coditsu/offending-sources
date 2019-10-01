# frozen_string_literal: true

# Base operation class for all application operations
# It uses trailblazer steps style for injection of keyword arguments
class ApplicationOperation
  class_attribute :steps

  class << self
    # DSL for adding step like operation flow
    # @param name [Symbol] name of the method that should be invoked
    def step(name)
      self.steps ||= []
      self.steps << name
    end

    # Executes the given steps in a flow
    # @param params [Hash] hash with initial params
    # @return [Accumulator] result accumulator with aggregated data
    # @raise [Errors::OperationFailure] operation failure if the result value of the step
    #   execution is false or nil
    def call(params = {})
      accu = Accumulator.new.merge!(params: params)
      instance = new

      steps.each do |name|
        result = instance.send(name, accu, **accu)

        raise(Errors::OperationFailure, [name, instance, accu]) unless result
      end

      accu
    end
  end

  # @return [Pathname] pathname to a location where our prepared data files should be stored
  # @example For Ruby::OutdatedGems::Reload
  #   sources_path #=> 'rails_root/public/outdated_gems/'
  def sources_path
    Rails.root.join(*(['public'] + self.class.to_s.underscore.split('/')[0...-1]))
  end
end
