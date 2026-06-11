class RenameRunMarksToRuns < ActiveRecord::Migration[8.1]
  def change
    rename_table :run_marks, :runs
    rename_column :races, :run_marks_count, :runs_count
  end
end
