# frozen_string_literal: true

# This migration adds 'pgcrypto' extension to enable UUID in PostgreSQL
class EnableUuid < ActiveRecord::Migration[7.1]
  def change
    enable_extension 'pgcrypto'
  end
end
