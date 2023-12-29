# frozen_string_literal: true

# This service is needed to create disbursement. It returns disursement or raises an error
# Arguments:
#   merchant: merchant
#   date: date of disbursement
#   values: array with gross_amount, total_fee and net_amount values
class CreateDisbursementService
  attr_reader :merchant, :date, :values

  def initialize(merchant, date, values)
    @merchant = merchant
    @date = date
    @values = values
  end

  def call
    create_disbursement(reference_name)
  end

  private

  # Ex: reichert_group_08_09_2022
  def reference_name
    "#{merchant.reference}_#{date.strftime('%d_%m_%Y')}"
  end

  def create_disbursement(reference)
    Disbursement.create!(
      reference: reference,
      gross_amount: values[:gross_amount],
      total_fee: values[:total_fee],
      net_amount: values[:net_amount]
    )
  end
end
