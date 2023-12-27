# frozen_string_literal: true

# 'disbursements' table to store information about all the orders for a merchant
# in a given day or week.
class Disbursement < ApplicationRecord
  has_many :orders

  validates! :reference, :gross_amount, :net_amount, :total_fee, presence: true
  validates! :reference, uniqueness: { case_sensitive: true }
  validates! :gross_amount, numericality: {}
  validates! :net_amount, numericality: {}
  validates! :total_fee, numericality: {}
end
