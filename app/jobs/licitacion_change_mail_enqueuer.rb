class LicitacionChangeMailEnqueuer
  @queue = :licitaciones_mail

  def self.perform(messages)
    users_ids = messages.keys

    users_ids.each do |user_id|.
      message = Redis.current.hmget("notification_emails", user_id)
    #TODO: Find some way to avoid Resqueception?
      Resque.enqueue(LicitacionChangeMailSender, user, result)
    end
  end

end