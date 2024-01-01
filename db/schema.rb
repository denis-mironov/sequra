# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2023_12_31_112307) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "disbursements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "reference", null: false
    t.decimal "gross_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "net_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "total_fee", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reference"], name: "index_disbursements_on_reference", unique: true
  end

  create_table "merchants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "reference", null: false
    t.string "email", null: false
    t.date "live_from", null: false
    t.integer "live_from_day"
    t.integer "disbursement_frequency", null: false
    t.decimal "minimum_monthly_fee", precision: 6, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_merchants_on_email", unique: true
    t.index ["reference"], name: "index_merchants_on_reference", unique: true
  end

  create_table "monthly_fees", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "merchant_id", null: false
    t.decimal "total_fee", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "fee_to_charge", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "year", null: false
    t.integer "month", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_monthly_fees_on_merchant_id"
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.boolean "disbursed", default: false, null: false
    t.string "reference", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "fee", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "net_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.uuid "disbursement_id"
    t.index ["disbursement_id"], name: "index_orders_on_disbursement_id"
    t.index ["reference"], name: "index_orders_on_reference"
  end

  add_foreign_key "monthly_fees", "merchants"
  add_foreign_key "orders", "disbursements"
  add_foreign_key "orders", "merchants", column: "reference", primary_key: "reference"
end
