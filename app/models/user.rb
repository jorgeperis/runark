class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :runs, dependent: :destroy

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_salt&.last(10)
  end

  def admin?
    admin
  end
  has_many :goals, dependent: :destroy

  GENDERS = %w[female male].freeze
  DEFAULT_FAVOURITE_DISTANCES = COMMON_RACE_DISTANCES.keys.freeze

  serialize :favourite_distances, coder: JSON, type: Array

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :gender, inclusion: { in: GENDERS }, allow_blank: true
  validate :favourite_distances_are_known

  before_validation :compact_favourite_distances

  def favourite_distance_keys
    keys = favourite_distances.presence || DEFAULT_FAVOURITE_DISTANCES
    COMMON_RACE_DISTANCES.keys & keys
  end

  def favourite_race_distances
    COMMON_RACE_DISTANCES.slice(*favourite_distance_keys)
  end

  def age_on(date)
    return if birthdate.blank?

    age = date.year - birthdate.year
    age -= 1 if date < birthdate + age.years
    age
  end

  def profile_complete?
    gender.present? && birthdate.present?
  end

  private

  def compact_favourite_distances
    self.favourite_distances = favourite_distances.compact_blank if favourite_distances.is_a?(Array)
  end

  def favourite_distances_are_known
    return if favourite_distances.blank?

    unknown = favourite_distances - COMMON_RACE_DISTANCES.keys
    errors.add(:favourite_distances, "contains unknown distances") if unknown.any?
  end
end
