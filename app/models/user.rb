class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :runs, dependent: :destroy
  has_many :goals, dependent: :destroy

  GENDERS = %w[female male].freeze

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :gender, inclusion: { in: GENDERS }, allow_blank: true

  def age_on(date)
    return if birthdate.blank?

    age = date.year - birthdate.year
    age -= 1 if date < birthdate + age.years
    age
  end

  def profile_complete?
    gender.present? && birthdate.present?
  end
end
