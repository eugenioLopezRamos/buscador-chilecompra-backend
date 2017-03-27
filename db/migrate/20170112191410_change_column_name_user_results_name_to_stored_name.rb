class ChangeColumnNameUserResultsNameToStoredName < ActiveRecord::Migration[5.0]
  def change
    rename_column :user_results, :name, :stored_group_name
  end
end
