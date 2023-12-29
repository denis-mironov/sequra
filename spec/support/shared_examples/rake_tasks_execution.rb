# frozen_string_literal: true

shared_examples 'doesn\'t create merchant' do
  it { expect { execute_task }.not_to change(Merchant, :count) }
end

shared_examples 'doesn\'t create order' do
  it { expect { execute_task }.not_to change(Order, :count) }
end

shared_examples 'outputs calculation start message' do
  it { expect { execute_task }.to output(start_message).to_stdout }
end

shared_examples 'outputs start and finish messages' do
  it { expect { execute_task }.to output(start_message).to_stdout }
  it { expect { execute_task }.to output(finish_message).to_stdout }
end

shared_examples 'outputs start message, finish message and error messages' do
  it { expect { execute_task }.to output(start_message).to_stdout }
  it { expect { execute_task }.to output(error_message).to_stdout }
  it { expect { execute_task }.to output(validation_error_message).to_stdout }
  it { expect { execute_task }.to output(finish_message).to_stdout }
end

shared_examples 'creates disbursement' do
  it 'creates disbursements' do
    expect { execute_task }.to change(
      Disbursement.where(
        reference: reference,
        gross_amount: gross_amount,
        total_fee: total_fee,
        net_amount: net_amount
      ), :count
    ).by(1)
  end
end

shared_examples 'sets order\'s disbursed value to true' do
  it 'sets orders disbursed value to true' do
    execute_task

    orders.each { |order| expect(order.disbursed).to be_truthy }
  end
end

shared_examples 'sets disbursement_id for order' do
  it 'sets disbursement_id for orders' do
    execute_task

    orders.each { |order| expect(order.disbursement_id).not_to be_nil }
  end
end
