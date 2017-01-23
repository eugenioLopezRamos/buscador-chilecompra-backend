class Notification < ApplicationRecord
  belongs_to :user

  def self.all_per_user

    result = Hash.new

    Notification.in_batches do |batch|

      batch.each do |notif|
        user = notif.user_id
        if !result[user]
          result[user] = [notif.message]
        else
          result[user].push(notif.message)
        end
      end

    end

    result
  end



end
