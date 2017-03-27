class AddUniqueIndexToUserResults < ActiveRecord::Migration[5.0]
  def change
    change_table :user_results do |t|
    t.index([:user_id, :result_id], unique: true)
    end
  end
end
