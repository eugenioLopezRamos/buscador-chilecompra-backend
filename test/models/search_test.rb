require 'test_helper'

class SearchTest < ActiveSupport::TestCase
 #logic is done in the controller since it is mostly related to the
 #response to be returned 
  def setup
    @minute_in_ms = 60 * 1000
    @time_at_start = Time.zone.now
  end

  test "If name is nil, make it Time.zone.now before_create" do
    test_search = Search.create(user_id: User.first.id, name: nil, value: "should be json")

    assert_not_equal test_search.name, nil
    assert test_search.name.to_i - @time_at_start.to_i < @minute_in_ms

  end

end
