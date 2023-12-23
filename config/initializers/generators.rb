# frozen_string_literal: true

# This configuration allows all models to use UUID for primary keys by default
Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
end
