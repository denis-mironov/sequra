# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/rake_tasks_execution'

describe 'rake disbursements:fill_daily', type: :task do
  Rake::DefaultLoader.new.load('lib/tasks/fill_daily_disbursements.rake')

  subject(:execute_task) { Rake::Task['disbursements:fill_daily'].execute }

  let(:merchant_1) { create(:merchant, :disbursed_daily) }
  let(:merchant_2) { create(:merchant, :disbursed_daily) }
  let(:merchant_3) { create(:merchant, :disbursed_weekly) }

  let(:order_date_1) { 3.days.ago }
  let(:order_date_2) { 5.days.ago }
  let(:order_date_3) { 4.days.ago }
  let(:order_date_4) { 2.days.ago }

  before do
    create(:order, :undisbursed, merchant: merchant_1, created_at: order_date_1.beginning_of_day)
    create(:order, :undisbursed, merchant: merchant_1, created_at: order_date_1.end_of_day)
    create(:order, :undisbursed, merchant: merchant_1, created_at: order_date_1)
    create(:order, :undisbursed, merchant: merchant_1, created_at: order_date_2)
    create(:order, :undisbursed, merchant: merchant_1, created_at: order_date_2.end_of_day)
    create(:order, :disbursed, merchant: merchant_1, created_at: order_date_2)

    create(:order, :undisbursed, merchant: merchant_2, created_at: order_date_3.beginning_of_day)
    create(:order, :undisbursed, merchant: merchant_2, created_at: order_date_3.end_of_day - 9.hours)
    create(:order, :undisbursed, merchant: merchant_2, created_at: order_date_4)
    create(:order, :undisbursed, merchant: merchant_2, created_at: order_date_4.end_of_day - 5.hours)
    create(:order, :disbursed, merchant: merchant_2, created_at: order_date_4)

    create(:order, :undisbursed, merchant: merchant_3, created_at: order_date_1.beginning_of_day)
    create(:order, :undisbursed, merchant: merchant_3, created_at: order_date_1.end_of_day)
  end

  context 'when there are no errors during the task execution' do
    let(:start_message) { /Disbursement creation started for #{merchant.reference}/ }
    let(:orders) { merchant.orders.undisbursed.where('date(created_at) = ?', order_date) }
    let(:values) { orders.pluck('SUM(amount)', 'SUM(fee)', 'SUM(net_amount)').flatten }
    let(:reference) { "#{merchant.reference}_#{order_date.strftime('%d_%m_%Y')}" }
    let(:gross_amount) { values[0] }
    let(:total_fee) { values[1] }
    let(:net_amount) { values[2] }

    context 'when disbursement for order_date_1 is created' do
      let(:merchant) { merchant_1 }
      let(:order_date) { order_date_1 }

      include_examples 'outputs calculation start message'
      include_examples 'creates disbursement'
      include_examples 'sets order\'s disbursed value to true'
      include_examples 'sets disbursement_id for order'
    end

    context 'when disbursement for order_date_2 is created' do
      let(:merchant) { merchant_1 }
      let(:order_date) { order_date_2 }

      include_examples 'outputs calculation start message'
      include_examples 'creates disbursement'
      include_examples 'sets order\'s disbursed value to true'
      include_examples 'sets disbursement_id for order'
    end

    context 'when disbursement for order_date_3 is created' do
      let(:merchant) { merchant_2 }
      let(:order_date) { order_date_3 }

      include_examples 'outputs calculation start message'
      include_examples 'creates disbursement'
      include_examples 'sets order\'s disbursed value to true'
      include_examples 'sets disbursement_id for order'
    end

    context 'when disbursement for order_date_4 is created' do
      let(:merchant) { merchant_2 }
      let(:order_date) { order_date_4 }

      include_examples 'outputs calculation start message'
      include_examples 'creates disbursement'
      include_examples 'sets order\'s disbursed value to true'
      include_examples 'sets disbursement_id for order'
    end
  end

  context 'when errors occur during the task execution' do
    let(:merchant_2) { create(:merchant, :disbursed_weekly) }
    let(:order_date_1_orders) { merchant_1.orders.undisbursed.where('date(created_at) = ?', order_date_1) }
    let(:order_date_2_orders) { merchant_1.orders.undisbursed.where('date(created_at) = ?', order_date_2) }
    let(:order_date_1_reference) { "#{merchant_1.reference}_#{order_date_1.strftime('%d_%m_%Y')}" }
    let(:order_date_2_reference) { "#{merchant_1.reference}_#{order_date_2.strftime('%d_%m_%Y')}" }

    context 'when disbursement creation failed' do
      before do
        allow(Disbursement).to receive(:create!)
          .with(hash_including(reference: order_date_1_reference))
          .and_raise(ActiveRecord::RecordInvalid)

        allow(Disbursement).to receive(:create!)
          .with(hash_including(reference: order_date_2_reference))
          .and_call_original
      end

      it 'doesn\'t create disbursement for order_date_1_orders' do
        execute_task

        expect(Disbursement.find_by(reference: order_date_1_reference)).to be_nil
      end

      it 'doesn\'t set disbursed value to true for order_date_1_orders' do
        execute_task

        order_date_1_orders.each { |order| expect(order.disbursed).to be_falsey }
      end

      it 'doesn\'t set disbursement_id for order_date_1_orders' do
        execute_task

        order_date_1_orders.each { |order| expect(order.disbursement_id).to be_nil }
      end

      it 'creates disbursement for order_date_2_orders' do
        execute_task

        expect(Disbursement.find_by(reference: order_date_2_reference)).not_to be_nil
      end

      it 'sets disbursed value to true for order_date_2_orders' do
        execute_task

        order_date_2_orders.each { |order| expect(order.disbursed).to be_truthy }
      end

      it 'sets disbursement_id for order_date_2_orders' do
        execute_task

        order_date_2_orders.each { |order| expect(order.disbursement_id).not_to be_nil }
      end
    end
  end
end
