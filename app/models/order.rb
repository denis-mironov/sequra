# frozen_string_literal: true

# 'orders' table to store information about the seQura's merchant partners' orders.
class Order < ApplicationRecord
  belongs_to :merchant, foreign_key: 'reference', primary_key: 'reference', inverse_of: :orders

  validates! :amount, :reference, presence: true
end
