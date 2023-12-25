# frozen_string_literal: true

require 'rails_helper'

shared_examples 'creates valid order' do
  it 'creates valid order' do
    expect { execute_task }.to change(
      Order.where(
        reference: reference,
        amount: amount
      ), :count
    ).by(1)
  end
end

shared_examples 'doesn\'t create order' do
  it { expect { execute_task }.not_to change(Order, :count) }
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

describe 'rake fill_table_with_data:orders', type: :task do
  Rails.application.load_tasks

  subject(:execute_task) { Rake::Task['fill_table_with_data:orders'].execute }

  let(:fixtures_folder_path) { 'spec/fixtures' }
  let(:file_path) { 'spec/fixtures/orders.csv' }
  let(:csv_file) { Rack::Test::UploadedFile.new(Rails.root.join(file_path), 'file/csv') }
  let(:created_records) { 1 }
  let(:failed_records) { 0 }
  let(:start_message) { /Process started/ }
  let(:finish_message) do
    /Process finished. Created records: #{created_records}, creation failed records: #{failed_records}/
  end

  let(:merchant) { create(:merchant) }
  let(:uuid) { 'da66b997-2b0f-4899-8fc1-1d1da5e31c3b' }
  let(:reference) { merchant.reference }
  let(:amount) { '25.0' }
  let(:created_at) { '12/25/2023' }

  let(:rows) do
    [
      %w[id merchant_reference amount created_at],
      [uuid, reference, amount, created_at]
    ]
  end

  before do
    FileUtils.mkdir_p(fixtures_folder_path)
    CSV.open(file_path, 'w') do |csv|
      rows.each { |row| csv << row }
    end

    csv_file.close

    allow(Rails.root).to receive(:join).with('db/csv_dumps/orders.csv').and_return(csv_file)
  end

  after { FileUtils.remove_dir(fixtures_folder_path) }

  context 'when all fields in .csv file are correct' do
    include_examples 'creates valid order'
    include_examples 'outputs start and finish messages'

    context 'when some fields in .csv file have empty spaces' do
      let(:rows) do
        [
          %w[id merchant_reference amount created_at],
          [uuid, reference, ' 25. 0', created_at]
        ]
      end

      include_examples 'creates valid order'
      include_examples 'outputs start and finish messages'
    end

    context 'when created_at field is absent' do
      let(:created_at) { nil }

      include_examples 'creates valid order' # created_at field sets automatically
      include_examples 'outputs start and finish messages'
    end
  end

  context 'when some fields in .csv file are incorrect' do
    let(:created_records) { 0 }
    let(:failed_records) { 1 }
    let(:error_message) { /Failed to create order. File row: 2/ }

    context 'when merchant for an order doesn\'t exist' do
      let(:reference) { 'invalid_reference' }
      let(:validation_error_message) { /Error message: Validation failed: Merchant must exist/ }

      include_examples 'doesn\'t create order'
      include_examples 'outputs start message, finish message and error messages'
    end

    context 'when created_at field is incorrect' do
      let(:created_at) { '12/123/2023' }
      let(:error_message) { /Failed to create order/ }
      let(:validation_error_message) { /Error message: invalid date/ }

      include_examples 'doesn\'t create order'
      include_examples 'outputs start message, finish message and error messages'
    end

    context 'when amount field is absent' do
      let(:amount) { nil }
      let(:validation_error_message) { /Error message: Amount can't be blank/ }

      include_examples 'doesn\'t create order'
      include_examples 'outputs start message, finish message and error messages'
    end

    context 'when reference field is absent' do
      let(:reference) { nil }
      let(:validation_error_message) { /Error message: Reference can't be blank/ }

      include_examples 'doesn\'t create order'
      include_examples 'outputs start message, finish message and error messages'
    end
  end
end
