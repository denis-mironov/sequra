# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    reference { Faker::Company.unique.name.downcase.parameterize.underscore }
    amount { 100 }
    fee { 0.95 }
    net_amount { 99.05 }
    disbursed { false }

    trait :disbursed do
      disbursed { true }
    end

    trait :undisbursed do
      disbursed { false }
    end
  end
end
