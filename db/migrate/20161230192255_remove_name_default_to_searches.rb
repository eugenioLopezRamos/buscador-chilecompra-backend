class RemoveNameDefaultToSearches < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:searches, :name, nil)
  end
end
