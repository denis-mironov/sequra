# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MonthlyFee do
  subject(:create_monthly_fee) { described_class.create!(attributes) }

  let(:merchant) { create(:merchant, minimum_monthly_fee: 50) }
  let(:total_fee) { 41.55 }
  let(:fee_to_charge) { 8.45 }
  let(:year) { 2022 }
  let(:month) { 'may' }
  let(:attributes) do
    {
      merchant: merchant,
      total_fee: total_fee,
      fee_to_charge: fee_to_charge,
      year: year,
      month: month
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:year).strict }
    it { is_expected.to validate_presence_of(:month).strict }
    it { is_expected.to validate_numericality_of(:year).strict }
    it { is_expected.to validate_numericality_of(:total_fee).strict }
    it { is_expected.to validate_numericality_of(:fee_to_charge).strict }
    it { described_class.months.keys { |month| is_expected.to allow_value(month).for(:month).strict } }

    context 'when all attributes are valid' do
      it { expect { create_monthly_fee }.to change(described_class, :count).by(1) }
      it { expect(create_monthly_fee).to be_valid }
      it { expect(create_monthly_fee.merchant.id).to match(merchant.id) }
      it { expect(create_monthly_fee.year).to match(year) }
      it { expect(create_monthly_fee.month).to match(month) }
      it { expect(create_monthly_fee.total_fee).to match(total_fee) }
      it { expect(create_monthly_fee.fee_to_charge).to match(fee_to_charge) }
    end
  end

  describe 'associations' do
    it { expect(described_class.reflect_on_association(:merchant).macro).to eq(:belongs_to) }
  end
end
