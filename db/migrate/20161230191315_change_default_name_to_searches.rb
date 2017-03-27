class ChangeDefaultNameToSearches < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:searches, :name, Time.now)
  end
end
