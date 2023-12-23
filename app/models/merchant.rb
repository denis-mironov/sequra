# frozen_string_literal: true

# 'merchants' table to store information about the seQura's merchant partners.
class Merchant < ApplicationRecord
  # has_many :orders, foreign_key: 'merchant_reference',
  #                   primary_key: 'merchant_reference',
  #                   dependent: nil,
  #                   inverse_of: 'merchant'

  enum live_from_day: Date::DAYS_INTO_WEEK, _prefix: :live_from_day_is
  enum disbursement_frequency: { daily: 0, weekly: 1 }, _default: :daily

  validates! :reference, :email, :live_from, :disbursement_frequency, presence: true
  validates! :email, uniqueness: { case_sensitive: false }, format: URI::MailTo::EMAIL_REGEXP
  validate :live_from_day_for_weekly_disbursement

  private

  def live_from_day_for_weekly_disbursement
    return unless disbursement_frequency.to_s == 'weekly'
    return if live_from_day.present?

    error_message = 'live_from_day can\'t be blank for \'weekly\' disbursement_frequency'
    raise ActiveModel::StrictValidationFailed, error_message: error_message
  end
end
