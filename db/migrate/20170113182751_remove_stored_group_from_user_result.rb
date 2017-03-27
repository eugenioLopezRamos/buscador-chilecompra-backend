class RemoveStoredGroupFromUserResult < ActiveRecord::Migration[5.0]
  def change
    remove_column :user_results, :stored_group_name
    remove_column :user_results, :stored_as_group
  end
end
