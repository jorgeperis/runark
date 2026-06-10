class FixRacesUniquenessIndexToScopeByUser < ActiveRecord::Migration[8.1]
  def change
    remove_index :races, name: "index_races_on_name_and_distance_and_location"
    add_index :races, [ :user_id, :name, :distance, :location ], unique: true, name: "index_races_on_user_id_name_distance_location"
  end
end
