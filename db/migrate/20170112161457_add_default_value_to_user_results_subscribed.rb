class AddDefaultValueToUserResultsSubscribed < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:user_results, :subscribed, false)
  end
end
