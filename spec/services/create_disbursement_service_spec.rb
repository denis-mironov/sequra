# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateDisbursementService do
  subject(:service_call) { described_class.new(merchant, date, values).call }

  let(:merchant) { create(:merchant) }
  let(:date) { Date.current }
  let(:gross_amount) { 100.0 }
  let(:total_fee) { 0.95 }
  let(:net_amount) { 91.05 }
  let(:reference) { "#{merchant.reference}_#{date.strftime('%d_%m_%Y')}" }
  let(:values) do
    {
      gross_amount: gross_amount,
      total_fee: total_fee,
      net_amount: net_amount
    }
  end

  context 'when disbursement is created successfully' do
    it 'creates disbursement' do
      expect { service_call }.to change(
        Disbursement.where(
          reference: reference,
          gross_amount: gross_amount,
          total_fee: total_fee,
          net_amount: net_amount
        ), :count
      ).by(1)
    end
  end

  context 'when disbursement creation is failed' do
    before { create(:disbursement, reference: reference) }

    it { expect { service_call }.to raise_error(ActiveModel::StrictValidationFailed) }
  end
end
