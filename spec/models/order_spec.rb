# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order do
  subject(:create_order) { described_class.create!(attributes) }

  let(:merchant) { create(:merchant) }
  let(:reference) { merchant.reference }
  let(:amount) { 500.55 }
  let(:attributes) do
    {
      reference: reference,
      amount: amount
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:reference).strict }
    it { is_expected.to validate_presence_of(:amount).strict }
    it { is_expected.to validate_numericality_of(:amount).strict }

    context 'when all attributes are valid' do
      it { expect { create_order }.to change(described_class, :count).by(1) }
      it { expect(create_order).to be_valid }
      it { expect(create_order.reference).to match(reference) }
      it { expect(create_order.amount).to match(amount) }
      it { expect(create_order.disbursed).to be_falsy }

      context 'when disbursed attribute is given' do
        before { attributes.merge!(disbursed: true) }

        it { expect(create_order.disbursed).to be_truthy }
      end
    end

    context 'when valid merchant for an order doesn\'t exist' do
      let(:reference) { 'invalid_reference' }
      let(:error_message) { 'Validation failed: Merchant must exist' }

      it 'returns validation error' do
        expect { create_order }.to raise_error(ActiveRecord::RecordInvalid, error_message)
      end
    end
  end

  describe 'callbacks' do
    let(:first_category_fee) { (amount.to_f * Order::FIRST_CATEGORY_FEE / 100.0).round(2) }
    let(:second_category_fee) { (amount.to_f * Order::SECOND_CATEGORY_FEE / 100.0).round(2) }
    let(:third_category_fee) { (amount.to_f * Order::THIRD_CATEGORY_FEE / 100.0).round(2) }
    let(:first_net_ammount) { (amount.to_f - first_category_fee.to_f).round(2) }
    let(:second_net_ammount) { (amount.to_f - second_category_fee.to_f).round(2) }
    let(:third_net_ammount) { (amount.to_f - third_category_fee.to_f).round(2) }

    context 'when amount is less than 50' do
      let(:amount) { 49.99 }

      it { expect { create_order }.to change(described_class, :count).by(1) }
      it { expect(create_order).to be_valid }
      it { expect(create_order.fee).to match(first_category_fee) }
      it { expect(create_order.net_amount).to match(first_net_ammount) }
    end

    context 'when amount is between 50 and 300' do
      let(:amount) { 50.0 }

      it { expect { create_order }.to change(described_class, :count).by(1) }
      it { expect(create_order).to be_valid }
      it { expect(create_order.fee).to match(second_category_fee) }
      it { expect(create_order.net_amount).to match(second_net_ammount) }
    end

    context 'when amount is greater than 300' do
      let(:amount) { 300.01 }

      it { expect { create_order }.to change(described_class, :count).by(1) }
      it { expect(create_order).to be_valid }
      it { expect(create_order.fee).to match(third_category_fee) }
      it { expect(create_order.net_amount).to match(third_net_ammount) }
    end
  end

  describe 'associations' do
    it { expect(described_class.reflect_on_association(:merchant).macro).to eq(:belongs_to) }
    it { expect(described_class.reflect_on_association(:disbursement).macro).to eq(:belongs_to) }
  end
end
