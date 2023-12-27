# frozen_string_literal: true

# 'orders' table to store information about the seQura's merchant partners' orders.
class Order < ApplicationRecord
  FIRST_CATEGORY_FEE = 1.00
  SECOND_CATEGORY_FEE = 0.95
  THIRD_CATEGORY_FEE = 0.85

  belongs_to :merchant, foreign_key: 'reference', primary_key: 'reference', inverse_of: :orders
  belongs_to :disbursement, optional: true

  validates! :amount, :reference, presence: true
  validates! :amount, numericality: {}

  before_save :calculate_fee
  before_save :calculate_net_amount

  private

  def calculate_fee
    self.fee = (amount.to_f * fee_percent / 100.0).round(2)
  end

  def calculate_net_amount
    self.net_amount = (amount.to_f - fee.to_f).round(2)
  end

  # returns a fee percent based on order's amount (€)
  def fee_percent
    if amount < 50
      FIRST_CATEGORY_FEE
    elsif amount >= 50 && amount < 300
      SECOND_CATEGORY_FEE
    elsif amount >= 300
      THIRD_CATEGORY_FEE
    end
  end
end
