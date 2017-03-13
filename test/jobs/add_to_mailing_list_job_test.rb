require 'test_helper'

class AddToMailingListJobTest < ActiveJob::TestCase

  test "test mock" do
    assert_enqueued_jobs 1
  end

  
end
