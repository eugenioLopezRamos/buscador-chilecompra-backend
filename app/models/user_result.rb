class UserResult < ApplicationRecord
  belongs_to :user
  belongs_to :result

  before_create :set_now_as_name_if_nil


  private
  def set_now_as_name_if_nil
    self.name = Time.now unless self.name
  end

end
