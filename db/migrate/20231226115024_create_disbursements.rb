# frozen_string_literal: true

# This migration creates new 'disbursements' table to store information about all the orders for a merchant
# in a given day or week.
class CreateDisbursements < ActiveRecord::Migration[7.1]
  def change
    create_table :disbursements, id: :uuid do |t|
      t.string :reference, null: false
      t.decimal :gross_amount, null: false, default: 0.0, precision: 10, scale: 2
      t.decimal :net_amount, null: false, default: 0.0, precision: 10, scale: 2
      t.decimal :total_fee, null: false, default: 0.0, precision: 10, scale: 2

      t.timestamps
    end

    add_index :disbursements, :reference, unique: true
  end
end
