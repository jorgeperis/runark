class AddUserToRacesAndRunMarks < ActiveRecord::Migration[8.1]
  def up
    add_reference :races, :user, foreign_key: true, null: true
    add_reference :run_marks, :user, foreign_key: true, null: true

    first_user_id = User.order(:id).limit(1).pick(:id)
    if first_user_id
      Race.update_all(user_id: first_user_id)
      execute "UPDATE run_marks SET user_id = (SELECT user_id FROM races WHERE races.id = run_marks.race_id)"
    end

    change_column_null :races, :user_id, false
    change_column_null :run_marks, :user_id, false
  end

  def down
    remove_reference :run_marks, :user
    remove_reference :races, :user
  end
end
