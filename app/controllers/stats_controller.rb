class StatsController < ApplicationController
  def index
    @best_marks = current_user.runs.best_common_distances
    @last_run = current_user.runs.ordered.first
    @top_runs_by_distance = FAVOURITE_RACE_DISTANCES.keys.index_with do |distance|
      current_user.runs.where(distance: distance).order(:time).limit(3)
    end
  end
end
