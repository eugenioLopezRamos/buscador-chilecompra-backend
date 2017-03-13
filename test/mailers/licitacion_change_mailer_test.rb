require 'test_helper'

class LicitacionChangeMailerTest < ActionMailer::TestCase

  test "Mock do" do
    assert !ActionMailer::Base.deliveries.empty?
  end



end
