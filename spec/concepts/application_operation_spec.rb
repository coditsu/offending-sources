# frozen_string_literal: true

RSpec.describe ApplicationOperation do
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

  it "expands operation with 'current_operation' context" do
    expect(completed_operation['current_operation']).to eq sample_operation
  end

  it "expands operation with 'current_step' context" do
    expect(completed_operation['current_step']).to eq :first_step
  end
end
