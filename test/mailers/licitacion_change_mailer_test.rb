require 'test_helper'

class LicitacionChangeMailerTest < ActionMailer::TestCase

  def setup
    @message = "Message1\nMessage2\n Message three is special\n"
    @user = User.first
    @class = LicitacionChangeMailer
  end

  test "send_notification_email forms the email correctly" do

    mail = @class.send_notification_email(@user, @message)
    subject = "Buscador Chilecompra - Cambio en estado de licitacion"
    assert_equal [@user.email], mail.to
    assert_match "Message1", mail.body.encoded
    assert_match "Message2", mail.body.encoded
    assert_match "Message three is special", mail.body.encoded
    assert_includes mail.subject, subject

  end



end
