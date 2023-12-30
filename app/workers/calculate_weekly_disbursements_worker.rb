# frozen_string_literal: true

# This worker is needed for weekly disbursements calculation.
# It's launched by sidekiq scheduler (config/sidekiq.yml) every day at 4:30 AM
class CalculateWeeklyDisbursementsWorker
  include Sidekiq::Worker
  include OrderUtil

  sidekiq_options retry: false

  def perform
    Merchant.disbursed_weekly.each do |merchant|
      orders = merchant.last_week_undisbursed_orders
      next if orders.empty?

      ActiveRecord::Base.transaction do
        total_values = calculate_total_values(orders)

        disbursement = CreateDisbursementService.new(merchant, Date.current, total_values).call
        update_orders(orders, disbursement) if disbursement&.valid?
      end
    rescue StandardError => e
      Rails.logger.error(e.message)
    end
  end
end
