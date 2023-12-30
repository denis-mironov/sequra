shared_examples 'creates an instance of CreateDisbursementService' do
  it 'creates an instance of CreateDisbursementService' do
    perform_worker

    expect(CreateDisbursementService).to have_received(:new).with(merchant_1, reference_date, named_values)
  end
end

shared_examples 'calls CreateDisbursementService instance' do
  it 'calls CreateDisbursementService instance' do
    perform_worker

    expect(service_instance).to have_received(:call)
  end
end

shared_examples 'sets orders disbursed value to true' do
  it 'sets orders disbursed value to true' do
    perform_worker

    orders.each { |order| expect(order.disbursed).to be_truthy }
  end
end

shared_examples 'sets disbursement_id for orders' do
  it 'sets disbursement_id for orders' do
    perform_worker

    orders.each { |order| expect(order.disbursement_id).to match(disbursement.id) }
  end
end

shared_examples 'doesn\'t set orders disbursed value to true' do
  it 'doesn\'t set orders disbursed value to true' do
    perform_worker

    orders.each { |order| expect(order.disbursed).to be_falsey }
  end
end

shared_examples 'doesn\'t set disbursement_id for orders' do
  it 'doesn\'t set disbursement_id for orders' do
    perform_worker

    orders.each { |order| expect(order.disbursement_id).to be_nil }
  end
end
