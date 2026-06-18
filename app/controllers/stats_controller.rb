class StatsController < ApplicationController
  def index
    runs = current_user.runs

    @best_marks = runs.best_common_distances
    @last_run = runs.ordered.first
    @top_runs_by_distance = FAVOURITE_RACE_DISTANCES.keys.index_with do |distance|
      runs.where(distance: distance).order(:time).limit(3)
    end

    @total_races = runs.count
    @total_distance = runs.sum(:distance)
    @total_time = runs.sum(:time)
    @races_this_year = runs.for_year(Date.current.year).count

    @progression = FAVOURITE_RACE_DISTANCES.keys.index_with do |distance|
      runs.where(distance: distance)
          .includes(:race)
          .group_by { |run| run.date.year }
          .transform_values { |year_runs| year_runs.min_by(&:time) }
          .sort_by { |year, _| year }
    end
  end
end
