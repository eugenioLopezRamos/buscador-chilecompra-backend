require 'test_helper'

class LicitacionChangeMailerTest < ActionMailer::TestCase

  def setup
    @message = "Message1\nMessage2\n Message three is special\n"
    @user = User.first
    @class = LicitacionChangeMailer
  end

  test "send_notification_email forms the email correctly" do
    WebMock.allow_net_connect!
    mail = @class.new.send_notification_email(@user, @message)
  end



end
