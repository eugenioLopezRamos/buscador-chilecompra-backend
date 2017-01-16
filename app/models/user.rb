class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :omniauthable,:confirmable #No confirm success url for now
  include DeviseTokenAuth::Concerns::User

  has_many :searches
  has_many :user_results, :dependent => :delete_all
  has_many :results, :through => :user_results
  has_many :notificaciones

  def send_licitacion_change_email(licitacion)
    LicitacionChangeMailer.send_notification_email(self, licitacion).deliver_now
  end

######## SUBSCRIPTION METHODS
  def subscriptions
    @results_array = Array.new

    UserResult.where(user_id: self.id, subscribed: true)
      .pluck(:subscription_name, :result_id).each do |sub|
        current_result_hash = Hash.new
        current_result_hash[sub[0]] = sub[1]
        @results_array.push(current_result_hash) 
    end

    @results_array
  end

  def subscribed_to_result?(result_id)
    result = UserResult.where(user_id: self.id, result_id: result_id)
    !result.empty? && result.suscribed 
  end

  # def subscribe_to_result(result_id, name)
  #   UserResult.where(user_id: self.id, result_id: result_id).update_attributes(subscribed: true, subscription_name: name)
  # end

  def subscribe_to_result(result_id, name)
    UserResult.create(user_id: self.id, result_id: result_id, subscribed: true, subscription_name: name)
  end

  def update_result_subscription(result_id, name)
    UserResult.where(user_id: self.id, result_id: result_id).update_attribute(:subscription_name, name)
  end

  def cancel_result_subscription(result_id)
    UserResult.where(user_id: self.id, result_id: result_id).update_attributes(subscription_name: "", subscribed: false)
  end

  ##########################
  
end
