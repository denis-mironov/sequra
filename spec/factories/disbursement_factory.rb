# frozen_string_literal: true

FactoryBot.define do
  factory :disbursement do
    reference { uniq_reference_name }
    gross_amount { 100 }
    total_fee { 0.95 }
    net_amount { 99.05 }
  end
end

def uniq_reference_name
  name = Faker::Company.unique.name.downcase.parameterize.underscore
  "#{name}_#{Date.current.strftime('%d_%m_%Y')}"
end
