class StatsController < ApplicationController
  def index
    runs = current_user.runs

    @favourite_distances = current_user.favourite_race_distances

    @best_marks = runs.best_common_distances.includes(:race).with_attached_image
    @last_run = runs.ordered.first
    @top_runs_by_distance = @favourite_distances.keys.index_with do |distance|
      runs.where(distance: distance).order(:time).limit(3)
    end

    @total_races = runs.count
    @total_distance = runs.sum(:distance)
    @total_time = runs.sum(:time)
    @races_this_year = runs.for_year(Date.current.year).count

    @progression = @favourite_distances.keys.index_with do |distance|
      runs.where(distance: distance)
          .includes(:race)
          .group_by { |run| run.date.year }
          .transform_values { |year_runs| year_runs.min_by(&:time) }
          .sort_by { |year, _| year }
    end

    current_year = Date.current.year
    @season = @progression.transform_values do |entries|
      by_year = entries.to_h
      { current: by_year[current_year], previous: by_year[current_year - 1] }
    end

    @activity = runs.group(
      Arel.sql("strftime('%Y', runs.date)"),
      Arel.sql("strftime('%m', runs.date)")
    ).count

    @scoring_available = AgeGrading.available?
  end
end
