class DropShoesAndMontlyDistances < ActiveRecord::Migration[8.1]
  def up
    drop_table :montly_distances
    drop_table :shoes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
