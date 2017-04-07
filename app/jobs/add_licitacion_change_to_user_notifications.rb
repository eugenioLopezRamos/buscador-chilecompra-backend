# Creates a new Notification for User when a licitacion they are subscribed to
# changes
class AddLicitacionChangeToUserNotifications
  @queue = :notificaciones

  def self.perform(codigo_externo)
    @users_to_notify = users_to_notify(codigo_externo)
    # No users to notify -> do nothing
    unless @users_to_notify.empty?
      create_users_notification(codigo_externo, @users_to_notify)
    end
    # If no more licitaciones need to be saved to DB,
    # then we can send all the notification_emails
    check_licitaciones_queue_size
  end

  def self.users_to_notify(codigo_externo)
    users = []
    User.in_batches do |batch|
      batch.each do |user|
        if user.subscriptions_by_codigo_externo.values.include?(codigo_externo)
          users.push(user.id)
        end
      end
    end
    users
  end

  def self.check_licitaciones_queue_size
    # Resque_unit has a slightly different API, it uses symbols instead of
    # strings like the real resque. TODO: Fix this somehow....
    licitaciones_queue = 'licitaciones'
    licitaciones_queue = licitaciones_queue.to_sym if Rails.env == 'test'
    return if Resque.size(licitaciones_queue) > 0
    # This returns a multikey hash with structure:
    # {user_id0: "message1blablah\n message2\n",
    #  userid1: "message3\n message4\n" }
    messages = Redis.current.hgetall('notification_emails')
    # Then we enqueue the creation of emails so they can be sent through
    # mailgun(or another service)
    Resque.enqueue(LicitacionChangeMailEnqueuer, messages)
  end

  def self.create_users_notification(codigo_externo, users)
    # Creates the notifications for the user in the db and
    # adds a redis hash with the structure:
    # {user_id1: "message1 \n message2 \n",
    #  user_id2: "message 3 \n message4 \n", ...}
    # which is a record of what messages will be sent to which users when all
    # licitaciones in the queue "licitaciones" are done being saved to the database

    # Returns a hash {"8": "cambios en xxxx \n cambios en yyyy \n cambios en zzz \n"}
    current_messages = Redis.current.hgetall('notification_emails')
    # TODO: try to refactor this? eg subscription_name to model?
    users.each do |user_id|
      subscription_name = User.find(user_id).subscription_name_by_codigo_externo(codigo_externo)
      message = "Cambios en la suscripción #{subscription_name} (cod.#{codigo_externo})"
      create_each_notification(user_id, message, current_messages)
    end
    Redis.current.hmset('notification_emails', *current_messages)
  end

  def self.create_each_notification(user_id, message, current_messages)
    notification = Notification.create(user_id: user_id,
                                       message: message)
    if notification.save
      user_message = create_user_message(user_id, current_messages, message)
      current_messages[user_id.to_s] = user_message
    else
      log_save_failure(user_id, codigo_externo)
    end
  end

  def self.create_user_message(user_id, current_messages, message)
    id = user_id.to_s
    return current_messages[id] + " #{message}\n" if current_messages[id]
    "#{message}\n"
  end

  def self.log_save_failure(user_id, codigo_externo)
    route = "#{Rails.root}/log/add_result_change_to_user_notifications.log"
    File.open(route, 'a+') do |f|
      f << "Error al guardar notificación para usuario id #{user_id}" \
           "por codigo externo #{codigo_externo} a las #{Time.zone.now} \n"
    end
  end
end
