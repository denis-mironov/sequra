# frozen_string_literal: true

# 'merchants' table to store information about the seQura's merchant partners.
class Merchant < ApplicationRecord
  has_many :orders, foreign_key: 'reference', primary_key: 'reference', dependent: :destroy, inverse_of: :merchant

  enum live_from_day: Date::DAYS_INTO_WEEK, _prefix: :live_from_day_is
  enum disbursement_frequency: { daily: 0, weekly: 1 }, _default: :daily, _prefix: :disbursed

  validates! :reference, :email, :live_from, :disbursement_frequency, presence: true
  validates! :email, uniqueness: { case_sensitive: false }, format: URI::MailTo::EMAIL_REGEXP
  validates! :reference, uniqueness: { case_sensitive: true }

  before_save :set_live_from_day_attribute, if: :disbursement_weekly?
  before_save :remove_live_from_day_attribute, if: :disbursement_daily?

  private

  def disbursement_weekly?
    disbursement_frequency.to_s == 'weekly'
  end

  def disbursement_daily?
    disbursement_frequency.to_s == 'daily'
  end

  def set_live_from_day_attribute
    self.live_from_day = live_from.strftime('%A').downcase
  end

  def remove_live_from_day_attribute
    self.live_from_day = nil if live_from_day.present?
  end
end
