# frozen_string_literal: true

# Base operation class for all application operations
# It wraps Trailblazer operation with some usefull additional steps when
# defining each step
class ApplicationOperation < Trailblazer::Operation
  extend Contract::DSL

  # We overwrite this method to inject after each step a step that will
  # remember what step was successfully executed as a last one (same of the operation class)
  # so it will be much easier to debug it in the future
  #
  # @param args Any arguments that original Trailblazer #step method defines
  def self.step(*args, &block)
    success ->(options, **) { options['current_operation'] ||= self }
    super(*args, &block)
    success ->(options) { options['current_step'] = args.first }
  end

  # @return [Pathname] pathname to a location where our prepared data files should be stored
  # @example For RubyGems::OutdatedGems::Reload
  #   sources_path #=> 'rails_root/public/outdated_gems/'
  def sources_path
    Rails.root.join *(['public'] + self.class.to_s.underscore.split('/')[0...-1])
  end
end
