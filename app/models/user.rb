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
      .each do |result|
        @results_hash[result[0]] = result[1]
      end

    @results_hash
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

end
