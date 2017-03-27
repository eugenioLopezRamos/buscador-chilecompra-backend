class AddNameToUserResults < ActiveRecord::Migration[5.0]
  def change

      add_column(:user_results, :name, :string)

  end
end
