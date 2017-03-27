class CreateUserResults < ActiveRecord::Migration[5.0]
  def change
    create_table :user_results do |t|
    
    t.integer :user_id
    t.integer :result_id
    t.timestamps

    end
  end
end
