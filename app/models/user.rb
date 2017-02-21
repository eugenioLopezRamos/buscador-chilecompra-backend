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

######## SUBSCRIPTION METHODS
  def subscriptions
    @results_hash = Hash.new

    UserResult.where(user_id: self.id, subscribed: true)
      .pluck(:subscription_name, :result_id)
      .each do |result|
        @results_hash[result[0]] = result[1]
      end

    @results_hash
  end

  def subscriptions_by_codigo_externo

    @subscriptions_by_codigo_externo = Hash.new
    self.subscriptions.each_pair do |name, result_id|
      result = Result.find(result_id).codigo_externo
      @subscriptions_by_codigo_externo[name] = result
    end

    @subscriptions_by_codigo_externo
  end

  def subscribed_to_result?(result_id)
    result = UserResult.where(user_id: self.id, result_id: result_id)
    !result.empty? && result.suscribed 
  end

  def subscribe_to_result(result_id, name)
    # Search if the user is already subscribed to result_id
    @codigo_externo = Result.find(result_id).value["Listado"][0]["CodigoExterno"]
    @codigo_externo_all_ids = Result.where("value -> 'Listado' -> 0 ->> 'CodigoExterno' = ?", @codigo_externo).pluck("id")
    #Returns the id of the results with CodigoExterno == @codigo_externo
    @user_subscriptions_codigos_externos = self.subscriptions.values.select {|value| @codigo_externo_all_ids.include? value}

    # If there are more than zero, the same CodigoExterno is already subscribed to!
    if @user_subscriptions_codigos_externos.length > 0
         
      @nombre_suscripcion = self.subscriptions.key(@user_subscriptions_codigos_externos[0])
      #TODO: Fix in controller too (Use a more appropiate error, ActiveRecord::RecordInvalid doesnt work as expected)
      raise ArgumentError, "Ya estás suscrito a la licitacion de código externo #{@codigo_externo} (Nombre suscripción: #{@nombre_suscripcion})"
    else
      UserResult.create(user_id: self.id, result_id: result_id, subscribed: true, subscription_name: name)
    end
  end

  def update_result_subscription(old_name, name)
    UserResult.where(user_id: self.id, subscription_name: old_name).each do |subscription|
      subscription.update_attribute(:subscription_name, name)
    end
  end

  def destroy_result_subscription(name)
    # Do note that [user_id, subscription_name] are unique composite indexes, so this should only affect one subscription at a time
    # (and each subscription is only to one result at a time)
    UserResult.where(user_id: self.id, subscription_name: name).each do |subscription|
      subscription.update_attributes(subscription_name: "", subscribed: false)
    end
  end

  def show_notifications
    @notif_hash = Hash.new
    notifications = self.notifications.pluck("id", "message")
    notifications.each do |notif|
      #notif[0] = the id, notif[1] = the message
      # so it returns a hash {notification_id: "notification message"} such as
      # {8: "Cambios en la licitacion 111-222-AAAA"}
      @notif_hash[notif[0]] = notif[1]
    end
      @notif_hash
  end

  def destroy_notification(notification_id)
    Notification.find(notification_id).destroy
  end

  def destroy_all_notifications
    Notification.where(user_id: self.id).each do |notif|
      notif.destroy
    end
  end

  private

  def add_user_to_mailing_list
    #TODO: Implement this job
    #AddToMailingList.perform(self)

  end


end
