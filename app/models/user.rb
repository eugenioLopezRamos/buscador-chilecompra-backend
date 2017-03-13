class User < ActiveRecord::Base
  # Include default devise modules.

  #TODO: Change devise messages....
  #TODO: Make the user confirm email address before making it valid.
  #TODO: Make devise not return user data to the client when registering,
  #be it successfully or unsuccessfully
  
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :omniauthable,:confirmable #No confirm success url for now
  include DeviseTokenAuth::Concerns::User
  include SearchesHelper

  has_many :searches
  has_many :user_results, :dependent => :delete_all
  has_many :results, :through => :user_results
  has_many :notifications, :dependent => :delete_all
  after_create :add_user_to_mailing_list

  def send_licitacion_change_email(message)
   # Message is a string with \n as line delimiters, which mark each individual message
   LicitacionChangeMailer.send_notification_email(self, message).deliver_later
  end

  def get_all_related_data
      
    @this_user = self.as_json
    @this_user[:searches] = show_searches(self)
    @this_user[:subscriptions] = self.subscriptions
    @this_user[:notifications] = self.notifications
    @this_user

  end

  def subscriptions
    UserResult.of_user(self)
  end

  def subscriptions_by_codigo_externo
    UserResult.subscriptions_by_codigo_externo_of(self)
  end

  def subscribed_to_result?(result_id)
    UserResult.user_subscribed_to?(self, result_id)
  end

  def subscribe_to_result(result_id, name)
    UserResult.subscribe_user_to_result(self, result_id, name)
  end

  def update_result_subscription(old_name, new_name)
    UserResult.update_subscription_of(self, old_name, new_name)
  end

  def destroy_result_subscription(name)
    UserResult.delete_user_subscription(self, name)
  end

  def show_notifications
    Notification.show_notifications_of(self)
  end

  def destroy_notification(notification_id)
    Notification.delete_notification_of_user(self.id, notification_id)
  end

  def destroy_all_notifications
    Notification.delete_all_notifications_of_user(self)
  end

  private

  def add_user_to_mailing_list
    #TODO: No need for mailing lists yet.

  end


end
