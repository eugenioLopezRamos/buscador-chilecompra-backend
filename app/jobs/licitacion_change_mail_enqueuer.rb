class LicitacionChangeMailEnqueuer
  @queue = :licitaciones_mail

  def self.perform(users, result)
    @users = User.where(id: users)

    @users.each do |user|
    #TODO: Find some way to avoid Resqueception?
      Resque.enqueue(LicitacionChangeMailSender, user, result)
    end
  end

end