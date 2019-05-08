# frozen_string_literal: true

FactoryBot.define do
  factory :ruby_gem, class: 'Ruby::RubyGem' do
    sequence :name do |n|
      "my_awesome_gem_#{n}"
    end

    sequence :slug do |n|
      "my_awesome_gem_#{n}"
    end

    trait :karafka do
      name { 'karafka' }
      slug { 'karafka' }
    end

    trait :another_gem do
      name { 'another_gem' }
      slug { 'another_gem' }
    end
  end
end
