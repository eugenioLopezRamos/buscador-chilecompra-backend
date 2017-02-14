class LicitacionChangeMailSender
  @queue = :licitaciones_mail

  def self.perform(user, licitacion)
    user.send_licitacion_change_email licitacion
  end
end