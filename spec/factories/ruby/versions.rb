# frozen_string_literal: true

FactoryBot.define do
  factory :ruby_version, class: 'Ruby::Version' do
    trait :with_different_numbers do
      sequence :number do |n|
        "#{n}.0.0"
      end
    end
  end
end
