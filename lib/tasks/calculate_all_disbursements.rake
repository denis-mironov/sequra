# frozen_string_literal: true

require 'csv'

# This task is needed for initial calculate of disbursements for all existing merchants and orders
# Execute task with an argument:
#   bash, zsh: rake disbursements:calculate_all
namespace :all_disbursements do
  desc 'Calculate disbursements for daily and weekly merchants'

  task calculate_daily: :environment do
    include DisbursementsHelper

    Merchant.disbursed_daily.each do |merchant|
      merchant_reference = merchant.reference
      puts "Disbursement creation started for #{merchant_reference}"

      merchant_orders = merchant.orders.not_disbursed

      merchant_order_dates(merchant_orders).each_key do |date|
        ActiveRecord::Base.transaction do
          one_day_orders = merchant_orders.where('date(created_at) = ?', date)
          one_day_total_values = calculate_total_values(one_day_orders)

          disbursement = create_disbursement(merchant_reference, date, one_day_total_values)
          update_orders(one_day_orders, disbursement) if disbursement&.valid?
        end
      rescue StandardError => e
        puts "Error: #{e.message}"
      end
    end
  end
end

# This helper module is needed for better structuring and maintainability of the rake task
module DisbursementsHelper
  def merchant_order_dates(orders)
    orders.group('date(created_at)').count
  end

  def calculate_total_values(one_day_orders)
    values = one_day_orders.pluck('SUM(amount)', 'SUM(fee)', 'SUM(net_amount)').flatten

    {
      gross_amount: values[0],
      total_fee: values[1],
      net_amount: values[2]
    }
  end

  def create_disbursement(merchant_reference, date, values)
    reference = reference_name(merchant_reference, date)

    Disbursement.create!(
      reference: reference,
      gross_amount: values[:gross_amount],
      total_fee: values[:total_fee],
      net_amount: values[:net_amount]
    )
  rescue StandardError
    puts "Failed to create disbursement. Reference: #{reference}"
    raise
  end

  # Ex: reichert_group_08_09_2022
  def reference_name(reference, date)
    "#{reference}_#{date.strftime('%d_%m_%Y')}"
  end

  # Does not trigger callbacks and validations
  # rubocop:disable Rails/SkipsModelValidations
  def update_orders(orders, disbursement)
    orders.update_all(disbursed: true, disbursement_id: disbursement.id)
  end
  # rubocop:enable Rails/SkipsModelValidations
end
