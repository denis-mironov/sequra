# frozen_string_literal: true

# This migration creates new 'monthly_fees' table to store information about the total fees charged
# to the merchant and fees to be charged by month and year.
class CreateMonthlyFees < ActiveRecord::Migration[7.1]
  def change
    create_table :monthly_fees, id: :uuid do |t|
      t.references :merchant, null: false, foreign_key: true, index: true, type: :uuid
      t.decimal :total_fee, null: false, default: 0.0, precision: 10, scale: 2
      t.decimal :fee_to_charge, null: false, default: 0.0, precision: 10, scale: 2
      t.integer :year, null: false
      t.integer :month, null: false

      t.timestamps
    end
  end
end
