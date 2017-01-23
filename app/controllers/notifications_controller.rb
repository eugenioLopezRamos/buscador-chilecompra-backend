class NotificationsController < ApplicationController
  
  def show
    render json: current_user.show_notifications
  end

  def destroy
    Notification.find(destroy_notification_params).destroy
  end

private
  
  def destroy_notification_params
    params.require(:notification).permit(:notification_id)
  end


end
