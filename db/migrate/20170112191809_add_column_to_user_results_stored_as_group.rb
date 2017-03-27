class AddColumnToUserResultsStoredAsGroup < ActiveRecord::Migration[5.0]
  def change
    add_column(:user_results, :stored_as_group, :bool)
  end
end
