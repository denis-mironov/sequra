# frozen_string_literal: true

# This task is needed to fill monthly_fees table with data based on merchants' and orders' data
# Note: calculate monthly fee for all merchants from their 'live_from' until the end of previous month.
# Execute: rake fill_table_with_data:monthly_fees
namespace :fill_table_with_data do
  desc 'Fills monthly_fees table'

  task monthly_fees: :environment do
    include MonthlyFeesHelper

    Merchant.find_each do |merchant|
      puts "\nMonthly fees calculation started for #{merchant.reference}"

      active_date_periods = years_and_months_active(merchant)

      active_date_periods.each do |period|
        year = period.keys.first
        month = period.values.first

        month_total_fee = one_month_fee(merchant, year, month)
        create_monthly_fee(merchant, year, month, month_total_fee)
      rescue StandardError => e
        puts "Error: #{e.message}\n"
      end
    end
  end
end

# helper module to provide clearance and maintanability of the code
module MonthlyFeesHelper
  # Ex: [{2022=>10}, {2022=>11}, {2022=>12}, {2023=>1}, ...]
  def years_and_months_active(merchant)
    (merchant.live_from..Date.current.prev_month).map { |date| { date.year => date.month } }.uniq
  end

  # returns total amount of fee for one merchant within specific year and month
  def one_month_fee(merchant, year, month)
    date_range = Date.new(year, month).all_month

    merchant.orders.where(created_at: date_range).sum(:fee)
  end

  def create_monthly_fee(merchant, year, month, month_total_fee)
    fee_to_charge = calculate_fee_to_charge(merchant, month_total_fee)

    MonthlyFee.create!(
      merchant_id: merchant.id,
      year: year.to_i,
      month: month.to_i,
      total_fee: month_total_fee,
      fee_to_charge: fee_to_charge
    )
  rescue StandardError
    puts "Failed to create monthly_fee. Year: #{year}, month: #{month}"
    raise
  end

  def calculate_fee_to_charge(merchant, month_total_fee)
    return MonthlyFee.column_defaults['fee_to_charge'] if month_total_fee >= merchant.minimum_monthly_fee

    merchant.minimum_monthly_fee - month_total_fee
  end
end
