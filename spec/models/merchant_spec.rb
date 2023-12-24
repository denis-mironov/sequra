# frozen_string_literal: true

require 'rails_helper'

shared_examples 'returns validation error' do |error|
  it 'returns validation error' do
    expect { create_merchant }.to raise_error(error, error_message)
  end
end

RSpec.describe Merchant do
  subject(:create_merchant) { described_class.create(attributes) }

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

  describe '.validates!' do
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
      context 'when reference is absent' do
        let(:reference) { nil }
        let(:error_message) { 'Reference can\'t be blank' }

        include_examples 'returns validation error', ActiveModel::StrictValidationFailed
      end

      context 'when email is absent' do
        let(:email) { nil }
        let(:error_message) { 'Email can\'t be blank' }

        include_examples 'returns validation error', ActiveModel::StrictValidationFailed
      end

      context 'when live_from is absent' do
        let(:live_from) { nil }
        let(:error_message) { 'Live from can\'t be blank' }

        include_examples 'returns validation error', ActiveModel::StrictValidationFailed
      end

      context 'when email has wrong format' do
        let(:email) { 'invlid_email' }
        let(:error_message) { 'Email is invalid' }

        include_examples 'returns validation error', ActiveModel::StrictValidationFailed
      end

      context 'when email is not unique' do
        let(:existing_merchant) { create(:merchant) }
        let(:email) { existing_merchant.email }
        let(:error_message) { 'Email has already been taken' }

        include_examples 'returns validation error', ActiveModel::StrictValidationFailed
      end

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

  describe '.before_save' do
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

  it { expect(described_class.reflect_on_association(:orders).macro).to eq(:has_many) }
end
