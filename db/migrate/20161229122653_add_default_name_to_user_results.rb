class AddDefaultNameToUserResults < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:user_results, :name, Time.now())
  end
end
