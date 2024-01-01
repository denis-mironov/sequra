# frozen_string_literal: true

# 'merchants' table to store information about the seQura's merchant partners
class Merchant < ApplicationRecord
  has_many :orders, foreign_key: 'reference', primary_key: 'reference', dependent: :destroy, inverse_of: :merchant
  has_many :disbursements, -> { distinct }, through: :orders
  has_many :monthly_fees, dependent: :destroy

  enum live_from_day: Date::DAYS_INTO_WEEK, _prefix: :live_from_day_is
  enum disbursement_frequency: { daily: 0, weekly: 1 }, _default: :daily, _prefix: :disbursed

  validates! :reference, :email, :live_from, :disbursement_frequency, presence: true
  validates! :email, uniqueness: { case_sensitive: false }, format: URI::MailTo::EMAIL_REGEXP
  validates! :reference, uniqueness: { case_sensitive: true }

  before_save :set_live_from_day_attribute, if: :disbursement_weekly?
  before_save :remove_live_from_day_attribute, if: :disbursement_daily?

  def yesterday_undisbursed_orders
    orders.undisbursed.where(created_at: Date.yesterday.all_day)
  end

  def last_week_undisbursed_orders
    orders.undisbursed.where(created_at: last_week)
  end

  def orders_created_within_a_week(period_of_time)
    orders.undisbursed.where(created_at: period_of_time)
  end

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

  # Ex: if disbursements are made weekly on Monday, then we consider all orders starting from
  # the previous Monday (beginning of the day) until Sunday (end of the day)
  def last_week
    (Date.current - 1.week).beginning_of_day..(Date.current - 1.day).end_of_day
  end
end
