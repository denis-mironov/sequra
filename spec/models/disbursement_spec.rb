# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Disbursement do
  subject(:create_disbursement) { described_class.create(attributes) }

  let(:reference) { 'store_reference_26_12_2023' }
  let(:total_fee) { 5.55 }
  let(:total_net_amount) { 555.5 }
  let(:attributes) do
    {
      reference: reference,
      total_fee: total_fee,
      total_net_amount: total_net_amount
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:reference).strict }
    it { is_expected.to validate_presence_of(:total_fee).strict }
    it { is_expected.to validate_presence_of(:total_net_amount).strict }
    it { is_expected.to validate_numericality_of(:total_fee).strict }
    it { is_expected.to validate_numericality_of(:total_net_amount).strict }
    it { is_expected.to validate_uniqueness_of(:reference).strict }

    context 'when all attributes are valid' do
      it { expect { create_disbursement }.to change(described_class, :count).by(1) }
      it { expect(create_disbursement).to be_valid }
      it { expect(create_disbursement.reference).to match(reference) }
      it { expect(create_disbursement.total_fee).to match(total_fee) }
      it { expect(create_disbursement.total_net_amount).to match(total_net_amount) }
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:orders) }
  end
end
