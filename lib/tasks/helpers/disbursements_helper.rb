# frozen_string_literal: true

# This helper module is needed for better structuring and maintainability of the rake task
module DisbursementsHelper
  def merchant_order_dates(orders)
    orders.group('date(created_at)').count
  end

  # returns all disbursement needed dates between live_from and current dates. For weekly disbursements
  def merchant_disbursement_dates(merchant)
    live_from_date = merchant.live_from

    (live_from_date..Date.current)
      .group_by(&:wday)[live_from_date.wday]
      .excluding(live_from_date)
  end

  # Ex: if disbursements are made weekly on Monday, then we consider all orders starting from
  # the previous Monday (beginning of the day) until Sunday (end of the day)
  def disbursement_period(date)
    (date - 1.week).beginning_of_day..(date - 1.day).end_of_day
  end

  # rubocop:disable Rails/Output
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
  # rubocop:enable Rails/Output

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
