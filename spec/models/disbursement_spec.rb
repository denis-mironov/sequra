# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Disbursement do
  subject(:create_disbursement) { described_class.create(attributes) }

  let(:reference) { 'store_reference_26_12_2023' }
  let(:total_fee) { 5.55 }
  let(:net_amount) { 555.50 }
  let(:gross_amount) { 561.05 }
  let(:attributes) do
    {
      reference: reference,
      total_fee: total_fee,
      gross_amount: gross_amount,
      net_amount: net_amount
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:reference).strict }
    it { is_expected.to validate_presence_of(:total_fee).strict }
    it { is_expected.to validate_presence_of(:gross_amount).strict }
    it { is_expected.to validate_presence_of(:net_amount).strict }
    it { is_expected.to validate_numericality_of(:total_fee).strict }
    it { is_expected.to validate_numericality_of(:gross_amount).strict }
    it { is_expected.to validate_numericality_of(:net_amount).strict }
    it { is_expected.to validate_uniqueness_of(:reference).strict }

    context 'when all attributes are valid' do
      it { expect { create_disbursement }.to change(described_class, :count).by(1) }
      it { expect(create_disbursement).to be_valid }
      it { expect(create_disbursement.reference).to match(reference) }
      it { expect(create_disbursement.total_fee).to match(total_fee) }
      it { expect(create_disbursement.net_amount).to match(net_amount) }
      it { expect(create_disbursement.gross_amount).to match(gross_amount) }
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:orders) }
  end
end
