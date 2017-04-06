# Enqueues notifications emails sent to users when a licitacion they are
# subscribed to changes.
class LicitacionChangeMailEnqueuer
  @queue = :mail

  def self.perform(messages)
    users_ids = messages.keys

    users_ids.each do |user_id|
      message = messages[user_id]
      User.find(user_id.to_i).send_licitacion_change_email(message)
    end
  end
end
