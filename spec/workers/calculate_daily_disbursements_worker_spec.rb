# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/shared_examples/workers_performing'

RSpec.describe CalculateDailyDisbursementsWorker do
  subject(:perform_worker) { described_class.new.perform }

  let(:merchant_1) { create(:merchant, :disbursed_daily) }
  let(:merchant_2) { create(:merchant, :disbursed_daily) }

  let(:yesterday_date_1) { Date.yesterday.beginning_of_day }
  let(:yesterday_date_2) { Date.yesterday.end_of_day }
  let(:yesterday_date_3) { Date.yesterday.end_of_day - 5.hours }

  let!(:order_1) { create(:order, :undisbursed, merchant: merchant_1, created_at: yesterday_date_1) }
  let!(:order_2) { create(:order, :undisbursed, merchant: merchant_1, created_at: yesterday_date_2) }
  let!(:order_3) { create(:order, :undisbursed, merchant: merchant_1, created_at: yesterday_date_3) }

  before do
    create(:order, :undisbursed, merchant: merchant_1, created_at: Date.current)
    create(:order, :disbursed, merchant: merchant_1, created_at: 2.days.ago)
    create(:order, :disbursed, merchant: merchant_1, created_at: yesterday_date_3)

    create(:order, :undisbursed, merchant: merchant_2, created_at: 2.days.ago)
    create(:order, :undisbursed, merchant: merchant_2, created_at: Date.current)
  end

  describe '#perform' do
    let(:service_instance) { instance_double(CreateDisbursementService, call: disbursement) }
    let(:disbursement) { create(:disbursement) }
    let(:reference_date) { Date.yesterday }
    let(:orders) { Order.where(id: [order_1.id, order_2.id, order_3.id]) }
    let(:values) { orders.pluck('SUM(amount)', 'SUM(fee)', 'SUM(net_amount)').flatten }
    let(:named_values) do
      {
        gross_amount: values[0],
        total_fee: values[1],
        net_amount: values[2]
      }
    end

    context 'when merchant is dibursed successfully' do
      before do
        allow(CreateDisbursementService).to receive(:new)
          .with(merchant_1, reference_date, named_values)
          .and_return(service_instance)
      end

      include_examples 'creates an instance of CreateDisbursementService'
      include_examples 'calls CreateDisbursementService instance'
      include_examples 'sets orders disbursed value to true'
      include_examples 'sets disbursement_id for orders'
    end

    context 'when merchant is disbursed with errors' do
      let(:error_message) { /Reference has already been taken/ }

      before do
        allow(Rails.logger).to receive(:error)
        allow(CreateDisbursementService).to receive(:new)
          .with(merchant_1, reference_date, named_values)
          .and_return(service_instance)
        allow(service_instance).to receive(:call).and_raise(ActiveModel::StrictValidationFailed, error_message)
      end

      include_examples 'creates an instance of CreateDisbursementService'
      include_examples 'calls CreateDisbursementService instance'
      include_examples 'doesn\'t set orders disbursed value to true'
      include_examples 'doesn\'t set disbursement_id for orders'

      it 'writes error log' do
        perform_worker

        expect(Rails.logger).to have_received(:error).with(error_message)
      end
    end
  end
end
