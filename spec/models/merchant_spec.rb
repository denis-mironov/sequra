# frozen_string_literal: true

require 'rails_helper'

shared_examples 'returns validation error' do |error|
  it 'returns validation error' do
    expect { subject }.to raise_error(error, error_message)
  end
end

RSpec.describe Merchant do
  subject(:create_merchant) { described_class.create!(attributes) }

  let(:reference) { 'store_reference' }
  let(:email) { 'info@store-reference.com' }
  let(:live_from) { Date.yesterday }
  let(:live_from_day) { Date.yesterday.strftime('%A').downcase }
  let(:disbursement_frequency) { 'daily' }
  let(:default_monthly_fee) { 0.0 }
  let(:attributes) do
    {
      reference: reference,
      email: email,
      live_from: live_from,
      disbursement_frequency: disbursement_frequency
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:reference).strict }
    it { is_expected.to validate_presence_of(:email).strict }
    it { is_expected.to validate_presence_of(:live_from).strict }
    it { is_expected.to validate_presence_of(:disbursement_frequency).strict }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive.strict }
    it { is_expected.to allow_value('info@store-reference.com').for(:email).strict }
    it { is_expected.not_to allow_value('store-reference.com').for(:email).strict }

    context 'when all attributes are valid' do
      it { expect { create_merchant }.to change(described_class, :count).by(1) }
      it { expect(create_merchant).to be_valid }
      it { expect(create_merchant.reference).to match(reference) }
      it { expect(create_merchant.email).to match(email) }
      it { expect(create_merchant.live_from).to match(live_from) }
      it { expect(create_merchant.live_from_day).to be_nil }
      it { expect(create_merchant.disbursement_frequency).to match(disbursement_frequency) }
      it { expect(create_merchant.minimum_monthly_fee).to match(default_monthly_fee) }

      context 'when minimum_monthly_fee is given' do
        let(:minimum_monthly_fee) { 15.0 }

        before do
          attributes.merge!(minimum_monthly_fee: minimum_monthly_fee)
        end

        it { expect(create_merchant.minimum_monthly_fee).to match(minimum_monthly_fee) }
      end
    end

    context 'when attributes are not valid' do
      context 'when reference is not unique' do
        let(:existing_merchant) { create(:merchant) }
        let(:reference) { existing_merchant.reference }
        let(:error_message) { 'Reference has already been taken' }

        include_examples 'returns validation error', ActiveModel::StrictValidationFailed
      end

      context 'when disbursement_frequency is not valid' do
        let(:disbursement_frequency) { 'monthly' }
        let(:error_message) { '\'monthly\' is not a valid disbursement_frequency' }

        include_examples 'returns validation error', ArgumentError
      end

      context 'when live_from_day is not valid' do
        let(:disbursement_frequency) { 'weekly' }
        let(:error_message) { '\'invalid day name\' is not a valid live_from_day' }

        before do
          allow(live_from).to receive(:strftime).and_return('invalid day name')
        end

        include_examples 'returns validation error', ArgumentError
      end
    end
  end

  describe 'callbacks' do
    context 'when merchant is weekly disbursed' do
      let(:disbursement_frequency) { 'weekly' }

      it 'sets live_from_day attribute according to live_from date' do
        expect(create_merchant.live_from_day).to match(live_from.strftime('%A').downcase)
      end
    end

    context 'when merchant is daily disbursed' do
      let(:disbursement_frequency) { 'daily' }

      it 'sets live_from_day to nil' do
        expect(create_merchant.live_from_day).to be_nil
      end
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:orders) }
  end
end
