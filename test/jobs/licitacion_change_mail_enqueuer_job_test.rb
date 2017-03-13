require 'test_helper'

class LicitacionChangeMailEnqueuerJobTest < ActiveJob::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "test mock " do
    assert_enqueued_jobs 1
  end
end
