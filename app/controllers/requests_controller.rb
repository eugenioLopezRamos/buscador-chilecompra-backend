class RequestsController < ApplicationController

  def search(params)

      @API_key = ENV['CC_TOKEN']
      @date = verify_correct_date(params[:date])

      #consulta de ejemplo, para pruebas.
      @URI = URI("http://api.mercadopublico.cl/servicios/v1/publico/licitaciones.json?fecha=#{@date}&ticket=" << @API_key)
      Net::HTTP.get URI

  end

  def test
      render json: {"test": "successful!"}
  end


  private

    def verify_correct_date(date)
        begin
            Date.parse(date)
            date.split("/")
            Date.valid_date? date[0].to_i, date[1].to_i, date[2].to_i
        raise ArgumentError
            "Fecha en formato inválido, por favor intentar de nuevo. Formato requerido: DD/MM/AAAA"
        end
    end




end
 