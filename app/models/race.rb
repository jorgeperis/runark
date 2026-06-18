class Race < ApplicationRecord
  has_many :runs, dependent: :restrict_with_error
  has_many :aliases, class_name: "Race", foreign_key: :merged_into_id, dependent: :nullify, inverse_of: :merged_into
  belongs_to :merged_into, class_name: "Race", optional: true, inverse_of: :aliases

  before_validation :set_normalized_name

  validates :name, presence: true
  validates :location, presence: true
  validates :distance, presence: true, numericality: { greater_than: 0 }
  validates :normalized_name, uniqueness: { scope: [ :distance, :location ], case_sensitive: false }

  scope :canonical, -> { where(merged_into_id: nil) }

  def self.normalize_name(name)
    ActiveSupport::Inflector.transliterate(name.to_s).downcase.squish
  end

  def self.search(query, limit: 10)
    normalized_query = normalize_name(query)
    canonical.where("normalized_name LIKE ?", "%#{sanitize_sql_like(normalized_query)}%")
             .order(:name)
             .limit(limit)
  end

  def canonical_race
    merged_into&.canonical_race || self
  end

  def best_run
    @best_run ||= runs.order(time: :asc).first
  end

  private

  def set_normalized_name
    self.normalized_name = self.class.normalize_name(name)
  end
end
