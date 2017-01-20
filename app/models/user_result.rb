class UserResult < ApplicationRecord
  belongs_to :user
  belongs_to :result

  after_update :delete_if_unused

  private

  def delete_if_unused
    if !self.subscribed
      self.destroy
    end
  end

end
