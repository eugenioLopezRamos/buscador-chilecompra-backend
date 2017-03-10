class AddLicitacionChangeToUserNotifications
 @queue = :notificaciones

  def self.perform(codigo_externo)
    @users_to_notify = get_users_to_notify(codigo_externo)

    if @users_to_notify.length > 0
      create_users_notification(codigo_externo, @users_to_notify)
    end
    #If no more licitaciones need to be saved to DB, then we can send all the notification_emails
    if Resque.queue_sizes["licitaciones"] == 0
      # This returns a multikey hash
      messages = Redis.current.hgetall("notification_emails")
    #To be enabled after setup is done with mailchimp/mandrill or some alternative
    #  Resque.enqueue(LicitacionChangeMailEnqueuer, messages)
    end
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

  def self.create_users_notification(codigo_externo, users)
    # Creates the notifications for the user in the db and 
    # adds a redis hash with the structure:
    # {user_id1: "message1 \n message2 \n",
    #  user_id2: "message 3 \n message4 \n", ...}
    # which is a record of what messages will be sent to which users when all
    # licitaciones in the queue "licitaciones" are done being saved to the database
    
    #Returns a hash {"8": "cambios en xxxx \n cambios en yyyy \n cambios en zzz \n"}
    current_values = Redis.current.hgetall("notification_emails")
    users.each do |user_id|
      
      subscription_name = user_id.subscriptions_by_codigo_externo.key(codigo_externo)
      message = "Cambios en la suscripción #{subscription_name} (cod.#{codigo_externo})"
      notification = Notification.create(user_id: user_id,
                                         message: message)

      if notification.save
        if !current_values[user_id.to_s]
          current_values[user_id.to_s] = message + "\n"
        else
          # #{message} is intentional, it adds a space before it.
          current_values[user_id.to_s] = current_values[user_id.to_s] + " #{message}" + "\n"
        end
      else !notification.save
        File.open("#{Rails.root}/log/add_result_change_to_user_notifications.log", "a+") do |f| 
          f << "Error al guardar notificación para usuario id #{user_id} por codigo externo #{codigo_externo} a las #{Time.now()} \n"
        end
      end
    end 


    Redis.current.hmset("notification_emails", *current_values)

  end

  


end