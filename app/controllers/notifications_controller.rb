class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: current_user.show_notifications
  end

  def destroy
  
   Notification.where(user_id: current_user.id,
                      id: destroy_notification_params[:notification_id])
                      .first
                      .destroy

   render json: json_message_to_frontend(info: "Notificación borrada con éxito",
                                         extra: {notifications: current_user.show_notifications})

   rescue ArgumentError => except
      render json: json_message_to_frontend(errors: except)
  end

private
  
  def destroy_notification_params
    if !is_integer? params["notification"]["notification_id"]
      raise ArgumentError, "Id debe ser un número entero"
    end

    params.require(:notification).permit(:notification_id)

  end


end
