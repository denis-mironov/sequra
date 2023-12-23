# frozen_string_literal: true

# This migration creates new 'merchants' table to store information about the seQura's merchant partners
class CreateMerchants < ActiveRecord::Migration[7.1]
  def change
    create_table :merchants, id: :uuid do |t|
      t.string :reference, null: false
      t.string :email, null: false
      t.date :live_from, null: false
      t.integer :live_from_day
      t.integer :disbursement_frequency, null: false
      t.decimal :minimum_monthly_fee, null: false, default: 0.0, precision: 6, scale: 2

      t.timestamps
    end

    add_index :merchants, :email, unique: true
  end
end
