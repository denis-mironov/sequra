# frozen_string_literal: true

# This migration adds unique index for 'monthly_fees' table for merchant, year and month fields,
# to avoid duplication records
class AddUniqueIndexForMonthlyFees < ActiveRecord::Migration[7.1]
  def change
    add_index :monthly_fees,
              %i[merchant_id year month],
              unique: true,
              name: 'index_unique_on_merchant_and_year_and_month'
  end
end
