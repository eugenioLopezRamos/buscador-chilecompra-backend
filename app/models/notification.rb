class Notification < ApplicationRecord
  belongs_to :user
  #add actions here instead of just creating htem on the controller/job

  def self.show_notifications_of(user)
    @notif_hash = Hash.new
    notifications = user.notifications.pluck("id", "message")
    notifications.each do |notif|
      #notif[0] = the id, notif[1] = the message
      # so it returns a hash {notification_id: "notification message"} such as
      # {8: "Cambios en la licitacion 111-222-AAAA"}
      @notif_hash[notif[0]] = notif[1]
    end
      @notif_hash
  end


  def self.delete_notification_of_user(user_id, notification_id)
    notification = self.where(id: notification_id, user_id: user_id)

    if notification.empty?
      raise ActiveRecord::RecordNotFound
    end
    
    notification.first.destroy
  end

  def self.delete_all_notifications_of_user(user_id)
    Notification.where(user_id: user_id).each do |notif|
      notif.destroy
    end
  end


end
