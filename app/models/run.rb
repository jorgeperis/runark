class Run < ApplicationRecord
  ACCEPTED_IMAGE_TYPES = %w[ image/png image/jpeg image/webp ].freeze
  MAX_IMAGE_SIZE = 8.megabytes

  belongs_to :user
  belongs_to :race, counter_cache: true

  has_one_attached :image

  validates :date, presence: true
  validates :time, presence: true, numericality: { greater_than: 0 }
  validates :distance, numericality: { greater_than: 0 }
  validate :acceptable_image

  before_validation :resolve_canonical_race, on: :create
  before_validation :set_defaults_from_race, on: :create

  SORTABLE_COLUMNS = {
    "date"     => "runs.date",
    "distance" => "runs.distance",
    "pace"     => "(runs.time * 1.0 / runs.distance)"
  }.freeze

  scope :ordered, -> { order(date: :desc) }
  scope :common_distances, -> { where(distance: COMMON_RACE_DISTANCES.keys) }

  scope :search_name, ->(query) {
    query.present? ? joins(:race).where("races.name LIKE ?", "%#{sanitize_sql_like(query)}%") : all
  }
  scope :for_year, ->(year) { year.present? ? where("strftime('%Y', runs.date) = ?", year.to_s) : all }
  scope :for_distance, ->(distance) { distance.present? ? where(distance: distance) : all }
  scope :for_race, ->(race) { race.present? ? where(race_id: race) : all }

  scope :sorted_by, ->(column, direction) {
    column    = SORTABLE_COLUMNS.fetch(column, SORTABLE_COLUMNS["date"])
    direction = direction.to_s.downcase == "asc" ? "ASC" : "DESC"
    order(Arel.sql("#{column} #{direction}"))
  }

  scope :with_min_time_per_distance, -> {
    order(:distance, :time).where("time = (SELECT MIN(time) FROM runs AS rm WHERE rm.distance = runs.distance)")
  }

  scope :best_common_distances, -> {
    common_distances.with_min_time_per_distance
  }

  def full_name
    "#{race.name} #{date.year}"
  end

  def pace
    (time / distance).round
  end

  def time_formatted
    return if time.blank?

    format("%d:%02d:%02d", time / 3600, (time % 3600) / 60, time % 60)
  end

  def time_formatted=(value)
    self.time = self.class.seconds_from_formatted(value)
  end

  def self.seconds_from_formatted(value)
    return if value.blank?

    hours, minutes, seconds = [ 0, 0, 0, *value.to_s.split(":") ].last(3).map(&:to_i)
    hours * 3600 + minutes * 60 + seconds
  end

  private

  def resolve_canonical_race
    self.race = race.canonical_race if race
  end

  def set_defaults_from_race
    self.distance ||= race.distance
  end

  def acceptable_image
    return unless image.attached?

    unless image.content_type.in?(ACCEPTED_IMAGE_TYPES)
      errors.add(:image, "must be a PNG, JPEG or WebP image")
    end

    if image.byte_size > MAX_IMAGE_SIZE
      errors.add(:image, "must be smaller than 8 MB")
    end
  end
end
