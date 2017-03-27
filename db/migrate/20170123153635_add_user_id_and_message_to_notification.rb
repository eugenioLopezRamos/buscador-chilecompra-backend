class AddUserIdAndMessageToNotification < ActiveRecord::Migration[5.0]
  def change
    add_column(:notifications, :user_id, :integer)
    add_column(:notifications, :message, :string)
  end
end
