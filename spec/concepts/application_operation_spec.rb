# frozen_string_literal: true

RSpec.describe_current do
  let(:sample_operation) do
    Class.new(described_class) do
      step :first_step

      def first_step(_ctx, *, **)
        true
      end
    end
  end

  let(:completed_operation) { sample_operation.call(params: 1) }

  it '#sources_path' do
    expect(sample_operation.new.sources_path).to be_a Pathname
  end
end
