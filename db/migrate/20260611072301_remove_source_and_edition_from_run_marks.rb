class RemoveSourceAndEditionFromRunMarks < ActiveRecord::Migration[8.1]
  def up
    remove_index :run_marks, name: "index_run_marks_on_race_id_and_edition"
    remove_column :run_marks, :edition, :integer
    remove_column :run_marks, :source, :string
  end

  def down
    add_column :run_marks, :source, :string, null: false, default: "chip"
    add_column :run_marks, :edition, :integer
    add_index :run_marks, [ :race_id, :edition ], unique: true, name: "index_run_marks_on_race_id_and_edition"
  end
end
