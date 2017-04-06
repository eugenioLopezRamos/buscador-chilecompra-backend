class Search < ApplicationRecord
  validates :value, presence: true
  belongs_to :user
  before_create :set_now_as_name_if_nil

  private

  def set_now_as_name_if_nil
    self.name = Time.zone.now unless name
  end
end
