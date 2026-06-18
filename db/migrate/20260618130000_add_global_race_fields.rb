class AddGlobalRaceFields < ActiveRecord::Migration[8.1]
  def up
    add_column :races, :normalized_name, :string
    add_column :races, :merged_into_id, :integer
    add_column :races, :certificate_number, :string

    Race.find_each do |race|
      normalized = ActiveSupport::Inflector.transliterate(race.name).downcase.squish
      race.update_columns(normalized_name: normalized)
    end

    change_column_null :races, :normalized_name, false
    add_foreign_key :races, :races, column: :merged_into_id
    add_index :races, :merged_into_id
  end

  def down
    remove_index :races, :merged_into_id
    remove_foreign_key :races, column: :merged_into_id
    remove_column :races, :certificate_number
    remove_column :races, :merged_into_id
    remove_column :races, :normalized_name
  end
end
