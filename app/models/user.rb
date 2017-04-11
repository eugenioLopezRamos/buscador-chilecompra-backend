# User data model
class User < ActiveRecord::Base
  # Include default devise modules.
  # TODO: Change devise messages....
  # TODO: Make devise not return user data to the client when registering,
  # be it successfully or unsuccessfully

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :confirmable
  include DeviseTokenAuth::Concerns::User
  include SearchesHelper

  has_many :searches
  has_many :user_results, dependent: :delete_all
  has_many :results, through: :user_results
  has_many :notifications, dependent: :delete_all

  def send_licitacion_change_email(message)
    # Message is a string with \n as line delimiters, which mark each individual
    # message
    MailerController.new.send_notification_email(self, message)
  end

  def all_related_data
    {
      user: as_json,
      searches: show_searches(self),
      subscriptions: subscriptions,
      notifications: show_notifications
    }
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
    codigo_externo = Result.find(result_id).codigo_externo
    UserResult.subscribe_user_to_result(self, result_id, codigo_externo, name)
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
    Notification.delete_notification_of_user(id, notification_id)
  end

  def destroy_all_notifications
    Notification.delete_all_notifications_of_user(self)
  end

  def subscription_name_by_codigo_externo(codigo_externo)
    subscriptions_by_codigo_externo.key(codigo_externo)
  end

  private

  def add_user_to_mailing_list
    # TODO: No need for mailing lists yet.
  end
end
