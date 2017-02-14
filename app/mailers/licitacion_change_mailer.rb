class LicitacionChangeMailer < ApplicationMailer

  def send_notification_email(user, message)
    @user = user
    @name = @user.name
    @greeting = "Hola!"
    @subject = "Buscador Chilecompra - Cambio en estado de licitacion"
    @message = message
    #TODO: Make decent templates
    mail to: @user.email, subject: @subject
  end

end
