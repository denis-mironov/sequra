# frozen_string_literal: true

# This migration adds next fields to the orders table:
#  - 'fee' field to store information about the order's fee
#  - 'disbursement_id' field to store information about the disbursement
class AddFeeAndDisbursementToOrdersTable < ActiveRecord::Migration[7.1]
  def change
    change_table :orders, bulk: true do |t|
      t.decimal :fee, null: false, default: 0.0, precision: 10, scale: 2
      t.decimal :net_amount, null: false, default: 0.0, precision: 10, scale: 2
    end

    add_reference :orders, :disbursement, type: :uuid, index: true, foreign_key: true
  end
end
