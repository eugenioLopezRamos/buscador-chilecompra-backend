require 'test_helper'

class LicitacionChangeMailEnqueuerJobTest < ActiveJob::TestCase
  # TODO: add a second user?
  def setup
    @messages = { '1' => "Message number one is this one\nMessage number two is this other one\n" }
    @job = LicitacionChangeMailEnqueuer
  end

  test "Email is enqueued to be #deliver_later'ed" do
    address = "https://api.mailgun.net/v3/#{ENV['MAIL_DOMAIN']}/messages"
    stub_request(:post, address)

    assert_difference 'Resque.size(:notificaciones)', 1 do
      Resque.enqueue(@job, @messages)
    end
  end

  test 'Job is executed' do
    perform_enqueued_jobs do
      address = "https://api.mailgun.net/v3/#{ENV['MAIL_DOMAIN']}/messages"
      stub_request(:post, address)
      @job.perform(@messages)
      assert_requested :post, address, times: 1
    end
  end
end
