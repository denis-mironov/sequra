# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/rake_tasks_execution'

shared_examples 'creates monthly_fee' do
  it 'creates monthly_fee' do
    expect { execute_task }.to change(
      MonthlyFee.where(
        merchant_id: merchant.id,
        year: 2023,
        month: month,
        total_fee: total_fee,
        fee_to_charge: fee_to_charge
      ), :count
    ).by(1)
  end
end

describe 'rake fill_table_with_data:monthly_fees', type: :task do
  Rake::DefaultLoader.new.load('lib/tasks/fill_monthly_fees_table.rake')

  subject(:execute_task) { Rake::Task['fill_table_with_data:monthly_fees'].execute }

  let(:merchant) { create(:merchant, :disbursed_daily, live_from: '10/09/2023', minimum_monthly_fee: 10.0) }

  let(:september_2023_1) { '10/09/2023' }
  let(:september_2023_2) { '12/09/2023' }
  let(:october_2023_1) { '15/10/2023' }
  let(:october_2023_2) { '16/10/2023' }
  let(:october_2023_3) { '17/10/2023' }
  let(:november_2023_1) { '25/11/2023' }
  let(:january_2024_1) { '01/01/2024' }

  let!(:order_1) { create(:order, merchant: merchant, created_at: september_2023_1, amount: 700.0) }
  let!(:order_2) { create(:order, merchant: merchant, created_at: september_2023_2, amount: 500.0) }
  let!(:order_3) { create(:order, merchant: merchant, created_at: october_2023_1, amount: 450.55) }
  let!(:order_4) { create(:order, merchant: merchant, created_at: october_2023_2, amount: 499.99) }
  let!(:order_5) { create(:order, merchant: merchant, created_at: october_2023_3, amount: 550.0) }
  let!(:order_6) { create(:order, merchant: merchant, created_at: november_2023_1, amount: 359.99) }

  before do
    create(:order, merchant: merchant, created_at: january_2024_1)

    # this will allow to always calculate monthly_fee from September to December
    allow(Date.current).to receive(:prev_month).and_return(Date.new(2023, 12))
  end

  context 'when there are no errors during the task execution' do
    let(:start_message) { /Monthly fees calculation started/ }

    context 'when monthly_fee for September is calculated' do
      let(:month) { 'september' }
      let(:total_fee) { order_1.fee + order_2.fee }
      let(:fee_to_charge) { 0.0 }

      # include_examples 'outputs calculation start message'
      include_examples 'creates monthly_fee'
    end

    context 'when monthly_fee for October is calculated' do
      let(:month) { 'october' }
      let(:total_fee) { order_3.fee + order_4.fee + order_5.fee }
      let(:fee_to_charge) { 0.0 }

      include_examples 'outputs calculation start message'
      include_examples 'creates monthly_fee'
    end

    context 'when monthly_fee for November is calculated' do
      let(:month) { 'november' }
      let(:total_fee) { order_6.fee }
      let(:fee_to_charge) { merchant.minimum_monthly_fee - order_6.fee } # 6.94

      include_examples 'outputs calculation start message'
      include_examples 'creates monthly_fee'
    end

    context 'when monthly_fee for December is calculated' do
      let(:month) { 'december' }
      let(:total_fee) { 0.0 }
      let(:fee_to_charge) { 10.0 }

      include_examples 'outputs calculation start message'
      include_examples 'creates monthly_fee'
    end
  end

  context 'when monthly_fee creation failed for one of the months' do
    let(:failed_month) { MonthlyFee.months['september'] }
    let(:info_message) { /Failed to create monthly_fee. Year: 2023, month: #{failed_month}/ }
    let(:error_message) { /Error: ActiveModel::StrictValidationFailed/ }

    before do
      allow(MonthlyFee).to receive(:create!)
        .with(hash_including(year: 2023, month: failed_month))
        .and_raise(ActiveModel::StrictValidationFailed)

      allow(MonthlyFee).to receive(:create!).with(hash_including(year: 2023, month: 10)).and_call_original
      allow(MonthlyFee).to receive(:create!).with(hash_including(year: 2023, month: 11)).and_call_original
      allow(MonthlyFee).to receive(:create!).with(hash_including(year: 2023, month: 12)).and_call_original
    end

    it { expect { execute_task }.to output(info_message).to_stdout }
    it { expect { execute_task }.to output(error_message).to_stdout }

    it 'doesn\'t create monthly_fee for September' do
      execute_task

      expect(MonthlyFee.find_by(month: 'september')).to be_nil
    end

    it 'creates monthly_fee for October' do
      execute_task

      expect(MonthlyFee.find_by(month: 'october')).to be_valid
    end

    it 'creates monthly_fee for November' do
      execute_task

      expect(MonthlyFee.find_by(month: 'november')).to be_valid
    end

    it 'creates monthly_fee for December' do
      execute_task

      expect(MonthlyFee.find_by(month: 'december')).to be_valid
    end
  end
end
