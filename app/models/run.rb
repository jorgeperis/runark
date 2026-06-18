class Run < ApplicationRecord
  belongs_to :user
  belongs_to :race, counter_cache: true

  validates :date, presence: true
  validates :time, presence: true, numericality: { greater_than: 0 }
  validates :distance, numericality: { greater_than: 0 }
  validates :homologated, inclusion: { in: [ true, false ] }

  validate :race_belongs_to_user

  before_validation :set_defaults_from_race, on: :create

  SORTABLE_COLUMNS = {
    "date"     => "runs.date",
    "distance" => "runs.distance",
    "pace"     => "(runs.time * 1.0 / runs.distance)"
  }.freeze

  scope :ordered, -> { order(date: :desc) }
  scope :homologated, -> { where(homologated: true) }
  scope :common_distances, -> { where(distance: COMMON_RACE_DISTANCES.keys) }
  scope :favourite_distances, -> { where(distance: FAVOURITE_RACE_DISTANCES.keys) }

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

  scope :best_homologated_common_distances, -> {
    common_distances.homologated.with_min_time_per_distance
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

  def race_belongs_to_user
    errors.add(:race, :invalid) if race && user_id != race.user_id
  end

  def set_defaults_from_race
    self.distance ||= race.distance
    self.homologated ||= race.homologated
  end
end
