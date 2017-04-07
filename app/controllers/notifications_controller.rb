# Handles Notifications created for Users
class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :valid_destroy_notification_params, only: :destroy

  def show
    render json: current_user.show_notifications
  end

  def destroy
    Notification.delete_notification_of_user(current_user.id, valid_destroy_notification_params[:notification_id])
    render json: json_message_to_frontend(info: 'Notificación borrada con éxito',
                                          extra: { notifications: current_user.show_notifications })

  rescue ArgumentError => except
    render json: json_message_to_frontend(errors: except), status: 422
  rescue ActiveRecord::RecordNotFound
    return render json: json_message_to_frontend(errors: 'No se encontró dicha notificación'), status: 404
  end

  private

  def destroy_notification_params
    unless is_integer? params['notification']['notification_id']
      raise ArgumentError, 'Id debe ser un número entero'
    end

    params.require(:notification).permit(:notification_id)
  end

  def valid_destroy_notification_params
    params.require(:notification).permit(:notification_id)

  rescue ActionController::UnpermittedParameters, ActionController::ParameterMissing
    return render json: json_message_to_frontend(errors: 'Parámetros inválidos'), status: 422
  end
end
