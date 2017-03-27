class AddSubscribedToUserResults < ActiveRecord::Migration[5.0]
  def change
    add_column :user_results, :subscribed, :bool
    add_column :user_results, :subscription_name, :varchar
    add_column :user_results, :send_notification_email, :bool
  end
end
