# frozen_string_literal: true

require 'csv'
require_relative 'helpers/disbursements_helper'

# This task is needed for initial calculate of daily disbursements for all existing merchants
# Execute: all_disbursements:calculate_daily
namespace :all_disbursements do
  desc 'Calculate disbursements for daily merchants'

  task calculate_daily: :environment do
    include DisbursementsHelper

    Merchant.disbursed_daily.each do |merchant|
      merchant_reference = merchant.reference
      puts "Disbursement creation started for #{merchant_reference}"

      merchant_orders = merchant.orders.undisbursed
      puts 'There are no undisbursed orders for this merchant' if merchant_orders.empty?

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
