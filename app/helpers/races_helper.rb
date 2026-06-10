module RacesHelper
  def races_grouped_options
    current_user.races.order(distance: :asc).group_by(&:distance).map do |distance, races|
      [ decorated_distance_for(distance), races.pluck(:name, :id) ]
    end
  end
end
