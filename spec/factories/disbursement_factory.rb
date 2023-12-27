# frozen_string_literal: true

FactoryBot.define do
  factory :disbursement do
    reference { reference_name }
    total_fee { 5.55 }
    total_net_amount { 555.0 }
  end
end

def reference_name
  name = Faker::Company.unique.name.downcase.parameterize.underscore
  name + '_' + Date.today.strftime('%d_%m_%Y')
end
