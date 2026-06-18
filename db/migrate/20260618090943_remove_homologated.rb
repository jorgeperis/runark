class RemoveHomologated < ActiveRecord::Migration[8.1]
  def change
    remove_column :races, :homologated, :boolean, default: false, null: false
    remove_column :runs, :homologated, :boolean, default: false, null: false
  end
end
