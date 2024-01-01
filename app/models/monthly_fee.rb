# frozen_string_literal: true

# 'monthly_fees' table to store information about monthly fees to be charged from merchants.
# When a merchant generates less than the 'minimum_monthly_fee' of orders’ commissions in the previous month,
# we will charge the amount left, up to the 'minimum_monthly_fee' configured.
# Nothing will be charged if the merchant generated more fees than the 'minimum_monthly_fee'.
class MonthlyFee < ApplicationRecord
  belongs_to :merchant

  # {'January'=>1, 'February'=>2, 'March'=>3, ...}
  MONTHS = Date::MONTHNAMES.compact.map.with_index(1) { |month, index| [month.downcase, index] }.to_h.freeze

  enum month: MONTHS, _prefix: :for

  validates! :year, :month, presence: true
  validates! :total_fee, :fee_to_charge, :year, numericality: {}
  validates! :month, inclusion: { in: months.keys }
end
