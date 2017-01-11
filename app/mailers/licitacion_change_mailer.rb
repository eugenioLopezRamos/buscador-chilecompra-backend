class LicitacionChangeMailer < ApplicationMailer

  def send_notification_email(user, licitacion)
    @user = user
    @name = @user.name
    @greeting = "Hola!"
    @licitacion_description = licitacion.value["Listado"][0]["Items"]["Listado"]["Descripcion"]
    @licitacion_codigo_externo = licitacion.value["Listado"][0]["CodigoExterno"]
    @subject = "Buscador Chilecompra - Cambio en estado de licitacion"


    mail to: @user.email, subject: @subject
  end

end
