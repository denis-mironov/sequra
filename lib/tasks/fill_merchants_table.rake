# frozen_string_literal: true

require 'csv'

# This task is needed to parse a .csv file with merchants and fill merchants table.
# Execute task with an argument:
#   bash, zsh: rake fill_table_with_data:merchants
namespace :fill_table_with_data do
  desc 'Fills merchants table'

  task merchants: :environment do
    include MerchantsHelper

    @created_records = 0
    @failed_records = 0

    puts 'Process started'

    # TODO: store files in cloud
    csv_file = Rails.root.join('db/csv_dumps/merchants.csv')

    Merchant.transaction do
      CSV.foreach(
        csv_file,
        headers: true,
        converters: [empty_space_converter, date_converter]
      ).with_index(1) { |row, index| create_merchant(row, index) }
    end
  rescue StandardError => e
    puts 'Failed to create merchant'
    puts "Error message: #{e.message}"
  ensure
    puts "Process finished. Created records: #{@created_records}, creation failed records: #{@failed_records}\n\n"
  end
end

# This module is needed to avoid using methods and constants with the same names in other tasks,
# because methods inside the rake tasks are defined to the top level
module MerchantsHelper
  def empty_space_converter
    columns_to_convert = %w[reference email live_on disbursement_frequency]

    ->(field, field_info) { columns_to_convert.include?(field_info.header) ? field&.delete(' ') : field }
  end

  def date_converter
    ->(field, field_info) { field_info.header == 'live_on' ? convert_to_date(field) : field }
  end

  # converts 'live_on' field string to Date format to save correctly in the DB.
  def convert_to_date(field)
    Date.strptime(field, '%m/%d/%Y')
  end

  def create_merchant(row, index)
    Merchant.create!(
      reference: row['reference'],
      email: row['email'],
      live_from: row['live_on'],
      disbursement_frequency: row['disbursement_frequency']&.downcase,
      minimum_monthly_fee: row['minimum_monthly_fee']&.to_d
    )

    @created_records += 1
  rescue StandardError => e
    @failed_records += 1

    puts "Failed to create merchant. File row: #{index + 1}"
    puts "Error message: #{e.message}"
  end
end
