# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/rake_tasks_execution'

shared_examples 'creates valid merchant' do
  it 'creates valid merchant' do
    expect { execute_task }.to change(
      Merchant.where(
        reference: reference,
        email: email,
        live_from: Date.strptime(live_on, '%m/%d/%Y'),
        live_from_day: live_from_day,
        disbursement_frequency: disbursement_frequency.downcase,
        minimum_monthly_fee: minimum_monthly_fee.to_d
      ), :count
    ).by(1)
  end
end

describe 'rake fill_table_with_data:merchants', type: :task do
  Rake::DefaultLoader.new.load('lib/tasks/fill_merchants_table.rake')

  subject(:execute_task) { Rake::Task['fill_table_with_data:merchants'].execute }

  let(:fixtures_folder_path) { 'spec/fixtures' }
  let(:file_path) { 'spec/fixtures/merchants.csv' }
  let(:csv_file) { Rack::Test::UploadedFile.new(Rails.root.join(file_path), 'file/csv') }
  let(:created_records) { 1 }
  let(:failed_records) { 0 }
  let(:start_message) { /Process started/ }
  let(:finish_message) do
    /Process finished. Created records: #{created_records}, creation failed records: #{failed_records}/
  end

  let(:uuid) { 'da66b997-2b0f-4899-8fc1-1d1da5e31c3b' }
  let(:reference) { 'rosenbaum_parisian' }
  let(:email) { 'info@rosenbaum-parisian.com' }
  let(:live_on) { '12/25/2023' }
  let(:live_from_day) { nil }
  let(:disbursement_frequency) { 'DAILY' }
  let(:minimum_monthly_fee) { '15.0' }

  let(:rows) do
    [
      %w[id reference email live_on disbursement_frequency minimum_monthly_fee],
      [uuid, reference, email, live_on, disbursement_frequency, minimum_monthly_fee]
    ]
  end

  before do
    FileUtils.mkdir_p(fixtures_folder_path)
    CSV.open(file_path, 'w') do |csv|
      rows.each { |row| csv << row }
    end

    csv_file.close

    allow(Rails.root).to receive(:join).with('db/csv_dumps/merchants.csv').and_return(csv_file)
  end

  after { FileUtils.remove_dir(fixtures_folder_path) }

  context 'when all fields in .csv file are correct' do
    context 'when merchant with daily disbursement is created' do
      include_examples 'creates valid merchant'
      include_examples 'outputs start and finish messages'
    end

    context 'when merchant with weekly disbursement is created' do
      let(:disbursement_frequency) { 'WEEKLY' }
      let(:live_from_day) { Date.strptime(live_on, '%m/%d/%Y').strftime('%A').downcase } # 'monday'

      include_examples 'creates valid merchant'
      include_examples 'outputs start and finish messages'
    end

    context 'when some fields in .csv file have empty spaces' do
      let(:rows) do
        [
          %w[id reference email live_on disbursement_frequency minimum_monthly_fee],
          [uuid, 'rosen baum_parisi an', 'info @rosenbaum-parisian. com', ' 12/25/2023 ', 'DAILY ', minimum_monthly_fee]
        ]
      end

      include_examples 'creates valid merchant'
      include_examples 'outputs start and finish messages'
    end
  end

  context 'when some fields in .csv file are incorrect' do
    let(:created_records) { 0 }
    let(:failed_records) { 1 }
    let(:error_message) { /Failed to create merchant. File row: 2/ }

    context 'when disbursement_frequency field is incorrect' do
      let(:disbursement_frequency) { 'MONTHLY' }
      let(:validation_error_message) { /Error message: 'monthly' is not a valid disbursement_frequency/ }

      include_examples 'doesn\'t create merchant'
      include_examples 'outputs start message, finish message and error messages'
    end

    context 'when live_on field is incorrect' do
      let(:live_on) { '123/12/2023' }
      let(:failed_records) { 0 }
      let(:error_message) { /Failed to create merchant/ }
      let(:validation_error_message) { /Error message: invalid date/ }

      include_examples 'doesn\'t create merchant'
      include_examples 'outputs start message, finish message and error messages'
    end

    context 'when reference field is absent' do
      let(:reference) { nil }
      let(:validation_error_message) { /Error message: Reference can't be blank/ }

      include_examples 'doesn\'t create merchant'
      include_examples 'outputs start message, finish message and error messages'
    end

    context 'when email field is absent' do
      let(:email) { nil }
      let(:validation_error_message) { /Error message: Email can't be blank/ }

      include_examples 'doesn\'t create merchant'
      include_examples 'outputs start message, finish message and error messages'
    end

    context 'when live_on field is absent' do
      let(:live_on) { nil }
      let(:validation_error_message) { /Error message: Live from can't be blank/ }

      include_examples 'doesn\'t create merchant'
      include_examples 'outputs start message, finish message and error messages'
    end

    context 'when disbursement_frequency field is absent' do
      let(:disbursement_frequency) { nil }
      let(:validation_error_message) { /Error message: Disbursement frequency can't be blank/ }

      include_examples 'doesn\'t create merchant'
      include_examples 'outputs start message, finish message and error messages'
    end
  end

  context 'when .csv file to parse doesn\'t exist' do
    let(:created_records) { 0 }
    let(:failed_records) { 0 }
    let(:nonexistent_pathname) { '#<Pathname:/db/csv_dumps/non_existing.csv>' }
    let(:error_message) { /Failed to create merchant/ }
    let(:validation_error_message) { /Error message: No such file or directory/ }

    before do
      allow(Rails.root).to receive(:join).with('db/csv_dumps/merchants.csv').and_return(nonexistent_pathname)
    end

    include_examples 'doesn\'t create merchant'
    include_examples 'outputs start message, finish message and error messages'
  end
end
