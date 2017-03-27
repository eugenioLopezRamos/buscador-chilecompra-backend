class AddUniqueIndexToSearches < ActiveRecord::Migration[5.0]
  def change
    change_table :searches do |t|
      t.index([:user_id, :name], unique: true)
    end
  end
end
