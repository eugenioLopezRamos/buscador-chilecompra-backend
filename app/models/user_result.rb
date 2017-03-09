class UserResult < ApplicationRecord
  belongs_to :user
  belongs_to :result

  after_update :delete_if_unused

  def self.of_user(user)
    @results_hash = Hash.new

    UserResult.where(user_id: user.id, subscribed: true)
      .pluck(:subscription_name, :result_id)
      .each do |result|
        @results_hash[result[0]] = result[1]
      end

    @results_hash
  end

  def self.user_subscribed_to?(user, result_id)
    result = UserResult.where(user_id: user.id, result_id: result_id)
    !result.empty? && result.suscribed 
  end

  def self.subscriptions_by_codigo_externo_of(user)
    @subscriptions_by_codigo_externo = Hash.new

    UserResult.of_user(user).each_pair do |name, result_id|
      result = Result.find(result_id).codigo_externo
      @subscriptions_by_codigo_externo[name] = result
    end

    @subscriptions_by_codigo_externo
  end

  def self.update_subscription_of(user, old_name, new_name)
    UserResult.where(user_id: user.id, subscription_name: old_name).each do |subscription|
      subscription.update_attribute(:subscription_name, new_name)
    end
  end

  def self.subscribe_user_to_result(user, result_id, name)
    # Search if the user is already subscribed to result_id
    @codigo_externo = Result.find(result_id).codigo_externo
    @all_ids_with_codigo_externo = Result.all_with_codigo_externo(@codigo_externo).pluck("id")
    #Returns the ids of the results with CodigoExterno == @codigo_externo
    @user_subscriptions_to_codigo_externo = user.subscriptions.values.select {|value| @all_ids_with_codigo_externo.include? value}

    # If there are more than zero, the same CodigoExterno is already subscribed to!
    if @user_subscriptions_to_codigo_externo.length > 0
         
      @nombre_suscripcion = user.subscriptions.key(@user_subscriptions_to_codigo_externo[0])
      #TODO: Fix in controller too (Use a more appropiate error, ActiveRecord::RecordInvalid doesnt work as expected)
      raise ArgumentError, "Ya estás suscrito a la licitacion de código externo #{@codigo_externo} (Nombre suscripción: #{@nombre_suscripcion})"
    else
      UserResult.create(user_id: user.id, result_id: result_id, subscribed: true, subscription_name: name)
    end

  end

  def self.delete_user_subscription(user, name)
    # Do note that [user_id, subscription_name] are unique composite indexes, so this should only affect one subscription at a time
    # (and each subscription is only to one result at a time)
    UserResult.where(user_id: user.id, subscription_name: name).each do |subscription|
      subscription.update_attributes(subscription_name: "", subscribed: false)
    end
  end

  
  private

  def delete_if_unused
    if !self.subscribed
      self.destroy
    end
  end

end
