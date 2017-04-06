require 'test_helper'

class MailerControllerTest < ActionDispatch::IntegrationTest
  def setup
    @message = "Message1\nMessage2\n Message three is special\n"
    @user = User.first
    @class = MailerController
  end

  test 'send_notification_email forms the email correctly' do
    # WebMock.allow_net_connect!
    # will catch the request to mailgun
    address = "https://api.mailgun.net/v3/#{ENV['MAIL_DOMAIN']}/messages"
    stub_request(:post, address)

    mail = @class.new.send_notification_email(@user, @message)

    @kontroller = mail[:klass]
    @mailer = mail[:mailer]

    read_instance_var = ->(name) { @kontroller.instance_variable_get("@#{name}".to_sym) }

    user = read_instance_var.call('user')
    name = read_instance_var.call('name')
    greeting = read_instance_var.call('greeting')
    subject = read_instance_var.call('subject')
    message = read_instance_var.call('message')
    message_html = read_instance_var.call('message_html')

    assert_equal @user, user
    assert_equal @user.name, name
    assert_equal 'Hola!', greeting
    assert_equal 'Buscador Chilecompra - Cambio en estado de licitacion', subject
    assert_equal @message, message
    assert_match 'Message1', message_html
    assert_match 'Message2', message_html
    assert_match 'Message three is special', message_html
    assert_requested :post, address, times: 1
  end
end
