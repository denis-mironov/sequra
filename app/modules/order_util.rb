# frozen_string_literal: true

# This module contains useful methods related to orders and used in different parts of application
module OrderUtil
  def calculate_total_values(orders)
    values = orders.pluck('SUM(amount)', 'SUM(fee)', 'SUM(net_amount)').flatten

    {
      gross_amount: values[0],
      total_fee: values[1],
      net_amount: values[2]
    }
  end

  # Does not trigger callbacks and validations
  # rubocop:disable Rails/SkipsModelValidations
  def update_orders(orders, disbursement)
    orders.update_all(disbursed: true, disbursement_id: disbursement.id)
  end
  # rubocop:enable Rails/SkipsModelValidations
end
