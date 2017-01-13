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

  ######## STORED RESULT METHODS
  def stored_results
    UserResult.where(user_id: self.id, stored_as_group: true).pluck("stored_group_name")
  end
  #TODO: This is wrong
  def has_stored_result? result_id
    result = UserResult.where(user_id: self.id, result_id: result_id)
    !result.empty? && result.stored_as_group
  end

  def stored_result_detail name
    #TODO: this has to be able to be done in a better way...
    ids = UserResult.where(user_id: self.id, stored_as_group: true, stored_group_name: name).pluck("result_id")
    Result.where(id: ids)
  end

  def create_stored_results(result_ids, name)
    @successful = Hash.new   
    @failed = Hash.new
    @not_uniq = Hash.new
    #TODO: clean up + document this decently... TLDR create a record. If it already exists (ActiveRecord::RecordNotUnique), update the existing record.
    # If updating is falsy, raise ActiveRecordError add the result to the failed hash
    result_ids.each do |result|
     # binding.pry
      begin
        new_entry = UserResult.create(user_id: self.id, stored_group_name: name, stored_as_group: true, result_id: result)
        if new_entry.save
          @successful[result] = true
        end
        rescue ActiveRecord::RecordNotUnique
          #if update_attributes returns false/nil, raise ActiveRecordError. This should happen when the result isn't changed/the stored_group_name/user_id combo already exists
          begin
            if !UserResult.where(user_id: self.id, result_id: result).update_attributes(stored_group_name: name, stored_as_group: true)
              raise ActiveRecordError
              #only gets executed if the update_attributes is successful
              @successful[result] = true
            end  
            rescue ActiveRecord::ActiveRecordError
              @not_uniq[result] = true
          end
      end
    end
    return {info: {"Guardado con éxito": @successful.keys}, errors: {"Fallido": @failed.keys, "Duplicados": @not_uniq.keys} } 
  end



  def update_stored_result(name, new_name)
    @successful = Array.new
    @failed = Array.new

    UserResult.where(user_id: self.id, stored_group_name: name).in_batches do |batch|
      batch.each do |result|
        begin
          if result.update_attribute(:stored_group_name, new_name)
            @successful.push result
          end
        rescue ActiveRecordError
          @failed.push result
        end
      end
    end
    {"Guardado con exito": @successful, "Fallido": @failed}
  end

  def delete_stored_result result_name
    @successful = Array.new
    @failed = Array.new

    UserResult.where(user_id: self.id, stored_group_name: result_name).in_batches do |batch|

      batch.each do |result| 
        begin
        if result.update_attributes(stored_as_group: false, stored_group_name: "")
          @successful.push result
        end
        rescue ActiveRecordError
          @failed.push result
        end
      end
    end
    {"Removido con exito": @successful, "Fallido": @failed}
  end

###################################

######## SUBSCRIPTION METHODS
  def subscriptions
    UserResult.where(user_id: self.id, subscribed: true).pluck(:result_id)
  end

  def subscribed_to_result? result_id
    result = UserResult.where(user_id: self.id, result_id: result_id)
    !result.empty? && result.suscribed 
  end

  def subscribe_to_result(result_id, name)
    UserResult.where(user_id: self.id, result_id: result_id).update_attributes(subscribed: true, subscription_name: name)
  end

  def create_and_subscribe_to_result(result_id, name)
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
