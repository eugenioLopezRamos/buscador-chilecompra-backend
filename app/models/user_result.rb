class UserResult < ApplicationRecord
  belongs_to :user
  belongs_to :result

  #before_create :set_now_as_name_if_nil
  #TODO: este after_update está malo, verificar (al crear, los borra inmediatamente)
  after_update :delete_if_unused

  private
  # def set_now_as_name_if_nil
  #   self.stored_group_name = Time.now unless self.stored_group_name
  # end

  def delete_if_unused
    if !self.subscribed
      self.destroy
    end
  end

end
