class ChangeValueToJsonb < ActiveRecord::Migration[5.0]
  def change
    change_column(:searches, :value, :jsonb)
    change_column(:results, :value, :jsonb)
  end
end
