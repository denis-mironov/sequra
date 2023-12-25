# frozen_string_literal: true

require 'csv'

# This task is needed to parse a .csv file and fill orders table.
# Execute task with an argument:
#   bash, zsh: rake fill_table_with_data:orders
namespace :fill_table_with_data do
  desc 'Fills orders table'

  task orders: :environment do
    include OrdersHelper

    @created_records = 0
    @creation_failed_records = 0

    # TODO: store files in cloud
    csv_file = Rails.root.join('db/csv_dumps/orders.csv')

    puts 'Process started'

    CSV.foreach(
      csv_file,
      headers: true,
      converters: [empty_space_converter, date_time_converter]
    ).with_index(1) { |row, index| create_order(row, index) }
  rescue StandardError => e
    output_error_message(e)
  ensure
    puts "Process finished. Created records: #{@created_records}, creation failed records: #{@creation_failed_records}"
  end
end

# This module is needed to avoid using methods and constants with the same names in other tasks,
# because methods inside the rake tasks are defined to the top level
module OrdersHelper
  def empty_space_converter
    columns_to_convert = %w[merchant_reference amount]

    ->(field, field_info) { columns_to_convert.include?(field_info.header) ? field&.delete(' ') : field }
  end

  def date_time_converter
    ->(field, field_info) { field_info.header == 'created_at' ? convert_to_date_time(field) : field }
  end

  # converts 'created_at' field string to DateTime format to save correctly in the DB.
  def convert_to_date_time(field)
    DateTime.strptime(field, '%m/%d/%Y')
  end

  def create_order(row, index)
    Order.create!(
      reference: row['merchant_reference'],
      amount: row['amount']&.to_d,
      created_at: row['created_at'],
      updated_at: row['created_at']
    )

    @created_records += 1
  rescue StandardError => e
    output_error_message(e, index)
  end

  def output_error_message(error, index = nil)
    @creation_failed_records += 1

    puts "Failed to create order. File row: #{index.present? ? index + 1 : nil}"
    puts "Error message: #{error.message}\n\n"
  end
end
