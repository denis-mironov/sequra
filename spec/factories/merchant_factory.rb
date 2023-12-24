# frozen_string_literal: true

FactoryBot.define do
  factory :merchant do
    reference { Faker::Company.unique.name.downcase.parameterize.underscore }
    email { "info@#{reference.dasherize}.com" }
    live_from { Date.yesterday }
    minimum_monthly_fee { 15.0 }

    trait :disbursed_weekly do
      disbursement_frequency { 'weekly' }
    end

    trait :disbursed_daily do
      disbursement_frequency { 'daily' }
    end
  end
end
