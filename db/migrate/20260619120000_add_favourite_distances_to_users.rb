class AddFavouriteDistancesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :favourite_distances, :text
  end
end
