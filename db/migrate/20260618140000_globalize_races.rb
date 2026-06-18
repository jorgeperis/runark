class GlobalizeRaces < ActiveRecord::Migration[8.1]
  def up
    sql = <<~SQL
      SELECT normalized_name, distance, lower(location) AS loc
      FROM races
      GROUP BY normalized_name, distance, lower(location)
      HAVING count(*) > 1
    SQL

    connection.execute(sql).each do |group|
      races = Race.where(normalized_name: group["normalized_name"], distance: group["distance"])
                  .where("lower(location) = ?", group["loc"])
                  .order(:id)
      canonical_id = races.first.id
      dupe_ids = races.offset(1).pluck(:id)
      Run.where(race_id: dupe_ids).update_all(race_id: canonical_id)
      Race.where(id: dupe_ids).delete_all
    end

    Race.find_each { |r| Race.reset_counters(r.id, :runs) }

    add_index :races, [ :normalized_name, :distance, :location ], unique: true,
              name: "index_races_on_normalized_name_distance_location"

    remove_foreign_key :races, column: :user_id
    remove_index :races, name: "index_races_on_user_id_name_distance_location"
    remove_index :races, name: "index_races_on_user_id"
    remove_column :races, :user_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
