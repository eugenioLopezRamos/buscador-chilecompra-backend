class CreateBatches < ActiveRecord::Migration[5.0]
  def change
    create_table :batches do |t|
      t.jsonb :value

      t.timestamps
    end
  end
end
