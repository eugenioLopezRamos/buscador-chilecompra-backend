class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :omniauthable,:confirmable #No confirm success url for now
  include DeviseTokenAuth::Concerns::User

  has_many :searches
  has_many :user_results, :dependent => :delete_all
  has_many :results, :through => :user_results


  def send_licitacion_change_email(licitacion)
    LicitacionChangeMailer.send_notification_email(self, licitacion).deliver_now
  end

end
