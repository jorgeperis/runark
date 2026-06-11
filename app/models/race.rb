class Race < ApplicationRecord
  belongs_to :user
  has_many :runs, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: [ :user_id, :distance, :location ] }
  validates :location, presence: true
  validates :distance, presence: true, numericality: { greater_than: 0 }
  validates :homologated, inclusion: { in: [ true, false ] }

  def best_run
    @best_run ||= runs.order(time: :asc).first
  end
end
