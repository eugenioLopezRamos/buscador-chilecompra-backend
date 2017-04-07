# Handles results that the user has stored for posterity.
class UserResultsController < ApplicationController
  include UserResultsHelper

  before_action :authenticate_user!
  before_action :valid_create_result_subscription_params, only: :create
  before_action :valid_update_result_subscription_params, only: :update
  before_action :valid_destroy_result_subscription_params, only: :destroy
  before_action :valid_result_history_params, only: :show_history
  # before_action :valid_ids?, only: [:create, :update, :create_stored_result]

  def show
    render json: current_user.subscriptions
  end

  def create
    # TODO: move validation to before_action
    @result_id = valid_create_result_subscription_params[:result_id]
    @name = valid_create_result_subscription_params[:name]
    current_user.subscribe_to_result(@result_id, @name)
    new_subscriptions = current_user.subscriptions
    render json: json_message_to_frontend(info: 'Suscripción guardada exitosamente', extra: { subscriptions: new_subscriptions })
    # TODO: Fix in model too.
  rescue ArgumentError => message
    render json: json_message_to_frontend(errors: message), status: 422
  rescue ActiveRecord::RecordNotUnique
    render json: json_message_to_frontend(errors: 'Error, ya está suscrito a este resultado y/o nombre ya existe')
  end

  def update
    # TODO: Just use the result_id? old_name is not really needed - Could go either way
    @name = valid_update_result_subscription_params[:name]
    @old_name = valid_update_result_subscription_params[:old_name]

    if current_user.update_result_subscription(@old_name, @name)
      @message = json_message_to_frontend(info: 'Actualizado exitosamente',
                                          extra: { subscriptions: current_user.subscriptions })
      return render json: @message
    end

    render json: json_message_to_frontend(errors: 'Lo sentimos, hubo un error. Por favor inténtalo nuevamente')

  rescue ActiveRecord::RecordNotUnique
    render json: json_message_to_frontend(errors: 'Error, este nombre ya existe'), status: 422
  end

  def destroy
    @result = valid_destroy_result_subscription_params[:name]

    if current_user.destroy_result_subscription @result
      return render json: json_message_to_frontend(info: 'Suscripción cancelada exitosamente',
                                                   extra: { subscriptions: current_user.subscriptions })
    end

    render json: json_message_to_frontend(errors: 'No se pudo cancelar la suscripción'), status: 422

  rescue ActiveRecord::ActiveRecordError
    render json: json_message_to_frontend(errors: 'Error al cancelar la suscripción'), status: 422
  end

  def show_history
    # Looks for up a result by id, then calls its :history method
    # which brings up all the database entries WITH THE SAME CODIGOEXTERNO
    # chronologically (that is, ASC in SQL terms) and sends them to the json_message_to_frontend
    # which then does the comparison and presents the results to the end user
    @id = valid_result_history_params.to_i

    @result = Result.find(@id)

    render json: @result.history

  rescue ActiveRecord::RecordNotFound
    return render json: json_message_to_frontend(errors: 'No se encontró dicho registro.'), status: 404
  end

  private

  def valid_create_result_subscription_params
    params.require(:create_subscription).permit(:name, :result_id)
  rescue ActionController::UnpermittedParameters, ActionController::ParameterMissing
    render json: json_message_to_frontend(errors: 'Parámetros inválidos'), status: 422
  end

  def valid_update_result_subscription_params
    params.require(:update_subscription).permit(:old_name, :name)
  rescue ActionController::UnpermittedParameters, ActionController::ParameterMissing
    render json: json_message_to_frontend(errors: 'Parámetros inválidos'), status: 422
  end

  def valid_destroy_result_subscription_params
    params.require(:destroy_subscription).permit(:name)
  rescue ActionController::UnpermittedParameters, ActionController::ParameterMissing
    render json: json_message_to_frontend(errors: 'Parámetros inválidos'), status: 422
  end

  def valid_result_history_params
    unless is_integer? params[:id]
      raise ArgumentError, 'Id de resultado debe ser un número entero'
    end
    params.permit(:id).require(:id)

  rescue ArgumentError => e
    render json: json_message_to_frontend(errors: e)
  rescue ActionController::UnpermittedParameters, ActionController::ParameterMissing
    render json: json_message_to_frontend(errors: 'Parámetros inválidos'), status: 422
  end
end
