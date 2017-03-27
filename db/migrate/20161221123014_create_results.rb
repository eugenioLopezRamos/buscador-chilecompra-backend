class CreateResults < ActiveRecord::Migration[5.0]
  def change
    create_table :results do |t|
      t.json :value
      t.timestamps
    end
  end
end
