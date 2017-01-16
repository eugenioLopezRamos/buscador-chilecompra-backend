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
    @results_hash = Hash.new
    UserResult.where(user_id: self.id, subscribed: true)
      .pluck(:subscription_name, :result_id)
      .map do |result|

        @results_hash[result[0]] = result[1]

      end

    @results_hash
  end

  def subscription_history(result_id)
    # results_ids = UserResult.where(user_id: self.id, subscribed: true, subscription_name: result_name).pluck("result_id")
    
    # results_ids.each do |version|

    #   Result.where  

    # end

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

  def update_result_subscription(old_name, name)
    UserResult.where(user_id: self.id, subscription_name: old_name).each do |subscription|
      subscription.update_attribute(:subscription_name, name)
    end
  end

  def destroy_result_subscription(name)
    # Do note that [user_id, subscription_name] are unique indexes, so this should only affect one subscription at a time
    # (and each subscription is only to one result at a time)
    UserResult.where(user_id: self.id, subscription_name: name).each do |subscription|
      subscription.update_attributes(subscription_name: "", subscribed: false)
    end
  end

  ##########################
  
end
