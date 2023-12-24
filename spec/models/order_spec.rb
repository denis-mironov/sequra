# frozen_string_literal: true

require 'rails_helper'

shared_examples 'returns validation error' do
  it 'returns validation error' do
    expect { create_order }.to raise_error(ActiveModel::StrictValidationFailed, error_message)
  end
end

RSpec.describe Order do
  subject(:create_order) { described_class.create(attributes) }

  let(:merchant) { create(:merchant) }
  let(:reference) { merchant.reference }
  let(:amount) { 500.55 }
  let(:attributes) do
    {
      reference: reference,
      amount: amount
    }
  end

  describe '.validates!' do
    context 'when all attributes are valid' do
      it { expect { create_order }.to change(described_class, :count).by(1) }
      it { expect(create_order).to be_valid }
      it { expect(create_order.reference).to match(reference) }
      it { expect(create_order.amount).to match(amount) }
      it { expect(create_order.disbursed).to be_falsy }

      context 'when disbursed attribute is given' do
        before do
          attributes.merge!(disbursed: true)
        end

        it { expect(create_order.disbursed).to be_truthy }
      end
    end

    context 'when attributes are not valid' do
      context 'when reference is absent' do
        let(:reference) { nil }
        let(:error_message) { 'Reference can\'t be blank' }

        include_examples 'returns validation error'
      end

      context 'when amount is absent' do
        let(:amount) { nil }
        let(:error_message) { 'Amount can\'t be blank' }

        include_examples 'returns validation error'
      end

      context 'when valid merchant for an order doesn\'t exist' do
        let(:reference) { 'invalid_reference' }
        let(:error_message) { 'Validation failed: Merchant must exist' }

        it { expect { create_order }.not_to change(described_class, :count) }
        it { expect(create_order).not_to be_valid }
      end
    end
  end

  it { expect(described_class.reflect_on_association(:merchant).macro).to eq(:belongs_to) }
end
