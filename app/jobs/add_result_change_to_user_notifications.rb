class AddResultChangeToUserNotifications
 @queue = :notificaciones

  def self.perform(codigo_externo)
    @users_to_notify = get_users_to_notify(codigo_externo)
    create_users_notification(@users_to_notify)
  end

  def self.get_users_to_notify(codigo_externo)

    users_to_notify = Array.new
    User.in_batches do |batch|
      batch.each do |user|
        if user.subscriptions_by_codigo_externo.values.include?(codigo_externo)
          users_to_notify.push(user.id)
        end
      end
    end
    users_to_notify

  end

  def self.create_users_notification(users)

    users.each do |user_id|
      notification = Notification.create(user_id: user_id, message: "Cambios en la licitación #{codigo_externo}")
      if !notification.save
        File.open("#{Rails.root}/log/add_result_change_to_user_notifications.log", "a+") do |f| 
          f << "Error al guardar notificación para usuario id #{user_id} por codigo externo #{codigo_externo} a las #{Time.now()} \n"
        end
      end
    end 

  end


end