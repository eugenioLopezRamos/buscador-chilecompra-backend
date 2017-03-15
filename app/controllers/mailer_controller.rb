class MailerController < ApplicationController
  #needed to be able to use render_to_string
  include ActionView::Rendering

  def send_notification_email(user, message)
    #You need to enable ENV['MY_MAIL'] in mailgun or use a 
    #verified domain to be able to send the emails
    @user = user
    @name = @user.name
    @greeting = "Hola!"
    @subject = "Buscador Chilecompra - Cambio en estado de licitacion"
    @message = message

    # First, instantiate the Mailgun Client with your API key
    mg_client = Mailgun::Client.new ENV['MAILGUN_API_KEY']

    @message_html = render_to_string template: '../views/licitacion_change_mailer/send_notification_email.html.erb'
    # Define your message parameters
    message_params =  { from: "example@example.com",
                        to:   ENV['MY_MAIL'],
                        subject: @subject,
                        html: @message_html.to_s
                      }

    # Send your message through the client
    mail_sender = mg_client.send_message ENV['MAIL_DOMAIN'], message_params

    #return this so we can use it in our tests
    {klass: self, mailer: mail_sender}
  end

end
