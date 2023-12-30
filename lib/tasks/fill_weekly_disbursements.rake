# frozen_string_literal: true

require 'csv'
require_relative 'helpers/disbursements_helper'
require_relative '../../app/modules/order_util'

# This task is needed for initial calculate of weekly disbursements for all existing merchants
# Execute: rake disbursements:fill_weekly
namespace :disbursements do
  desc 'Calculate disbursements for weekly merchants'

  task fill_weekly: :environment do
    include DisbursementsHelper
    include OrderUtil

    Merchant.disbursed_weekly.each do |merchant|
      merchant_reference = merchant.reference
      puts "Disbursement creation started for #{merchant_reference}. Disbursement day: #{merchant.live_from_day}"

      merchant_disbursement_dates(merchant).each do |date|
        ActiveRecord::Base.transaction do
          one_week_orders = merchant.orders_created_within_a_week(disbursement_period(date))
          next if one_week_orders.empty?

          one_week_total_values = calculate_total_values(one_week_orders)
          disbursement = create_disbursement(merchant_reference, date, one_week_total_values)
          update_orders(one_week_orders, disbursement) if disbursement&.valid?
        end
      rescue StandardError => e
        puts "Error: #{e.message}"
      end
    end
  end
end
