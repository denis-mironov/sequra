# frozen_string_literal: true

# This migration creates new 'orders' table to store information about the seQura's merchant partners' orders
class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders, id: :uuid do |t|
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.boolean :disbursed, null: false, default: false
      t.string :reference, index: true, null: false

      t.timestamps
    end

    add_foreign_key :orders, :merchants, column: :reference, primary_key: :reference
  end
end
