# frozen_string_literal: true

require 'csv'
require_relative 'helpers/disbursements_helper'

# This task is needed for initial calculate of weekly disbursements for all existing merchants
# Execute: rake all_disbursements:calculate_weekly
namespace :all_disbursements do
  desc 'Calculate disbursements for weekly merchants'

  task calculate_weekly: :environment do
    include DisbursementsHelper

    Merchant.disbursed_weekly.each do |merchant|
      merchant_reference = merchant.reference
      puts "Disbursement creation started for #{merchant_reference}. Disbursement day: #{merchant.live_from_day}"

      merchant_disbursement_dates(merchant).each do |date|
        ActiveRecord::Base.transaction do
          one_week_orders = orders_created_within_a_week(merchant, date)
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
