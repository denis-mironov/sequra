# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/rake_tasks_execution'

describe 'rake disbursements:fill_weekly', type: :task do
  Rake::DefaultLoader.new.load('lib/tasks/fill_weekly_disbursements.rake')

  subject(:execute_task) { Rake::Task['disbursements:fill_weekly'].execute }

  let(:merchant) { create(:merchant, :disbursed_weekly, live_from: 4.weeks.ago) }
  let(:merchant_daily) { create(:merchant, :disbursed_daily) }

  let(:week_1_date_1) { 12.days.ago }                             # 2 weeks ago
  let(:week_1_date_2) { 8.days.ago.end_of_day }                   # 2 weeks ago
  let(:week_2_date_1) { 7.days.ago.beginning_of_day }             # 1 week ago
  let(:week_2_date_2) { 4.days.ago }                              # 1 week ago
  let(:week_3_date_1) { Date.current.beginning_of_day }           # current week
  let(:week_3_date_3) { Date.current.beginning_of_day + 9.hours } # current week

  let!(:order_1) { create(:order, :undisbursed, merchant: merchant, created_at: week_1_date_1, amount: 55.0) }
  let!(:order_2) { create(:order, :undisbursed, merchant: merchant, created_at: week_1_date_2, amount: 75.0) }
  let!(:order_3) { create(:order, :undisbursed, merchant: merchant, created_at: week_2_date_1, amount: 200.0) }
  let!(:order_4) { create(:order, :undisbursed, merchant: merchant, created_at: week_2_date_2, amount: 150.0) }
  let!(:order_5) { create(:order, :undisbursed, merchant: merchant, created_at: week_3_date_1, amount: 80.0) }

  let(:week_1_reference) { "#{merchant.reference}_#{1.week.ago.strftime('%d_%m_%Y')}" }
  let(:week_2_reference) { "#{merchant.reference}_#{Date.current.strftime('%d_%m_%Y')}" }
  let(:week_1_orders) { Order.where(id: [order_1.id, order_2.id]) }
  let(:week_2_orders) { Order.where(id: [order_3.id, order_4.id]) }

  before do
    create(:order, :disbursed, merchant: merchant, created_at: week_1_date_1)
    create(:order, :disbursed, merchant: merchant, created_at: week_1_date_2)
    create(:order, :undisbursed, merchant: merchant_daily, created_at: week_2_date_1)
    create(:order, :undisbursed, merchant: merchant_daily, created_at: week_2_date_2)
  end

  context 'when there are no errors during the task execution' do
    let(:start_message) { /Disbursement creation started for #{merchant.reference}/ }
    let(:values) { orders.pluck('SUM(amount)', 'SUM(fee)', 'SUM(net_amount)').flatten }
    let(:gross_amount) { values[0] }
    let(:total_fee) { values[1] }
    let(:net_amount) { values[2] }

    context 'when disbursement for week_1 is created' do
      let(:reference) { week_1_reference }
      let(:orders) { week_1_orders }

      include_examples 'outputs calculation start message'
      include_examples 'creates disbursement'
      include_examples 'sets order\'s disbursed value to true'
      include_examples 'sets disbursement_id for order'
    end

    context 'when disbursement for week_2 is created' do
      let(:reference) { week_2_reference }
      let(:orders) { week_2_orders }

      include_examples 'outputs calculation start message'
      include_examples 'creates disbursement'
      include_examples 'sets order\'s disbursed value to true'
      include_examples 'sets disbursement_id for order'
    end

    it 'doesn\'t create disbursement for current week\'s order_5' do
      execute_task

      expect(order_5.disbursed).to be_falsey
    end
  end

  context 'when errors occur during the task execution' do
    context 'when disbursement creation failed' do
      before do
        allow(Disbursement).to receive(:create!)
          .with(hash_including(reference: week_1_reference))
          .and_raise(ActiveRecord::RecordInvalid)

        allow(Disbursement).to receive(:create!)
          .with(hash_including(reference: week_2_reference))
          .and_call_original
      end

      it 'doesn\'t create disbursement for week_1_orders' do
        execute_task

        expect(Disbursement.find_by(reference: week_1_reference)).to be_nil
      end

      it 'doesn\'t set disbursed value to true for week_1_orders' do
        execute_task

        week_1_orders.each { |order| expect(order.disbursed).to be_falsey }
      end

      it 'doesn\'t set disbursement_id for week_1_orders' do
        execute_task

        week_1_orders.each { |order| expect(order.disbursement_id).to be_nil }
      end

      it 'creates disbursement for week_2_orders' do
        execute_task

        expect(Disbursement.find_by(reference: week_2_reference)).not_to be_nil
      end

      it 'sets disbursed value to true for week_2_orders' do
        execute_task

        week_2_orders.each { |order| expect(order.disbursed).to be_truthy }
      end

      it 'sets disbursement_id for week_2_orders' do
        execute_task

        week_2_orders.each { |order| expect(order.disbursement_id).not_to be_nil }
      end
    end
  end
end
