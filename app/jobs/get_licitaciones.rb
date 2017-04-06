# Gets all licitaciones at time it is run (as a batch), then enqueues saving the
# batch and starts to get each individual licitacion (which is more detailed)
class GetLicitaciones
  @queue = :licitaciones
  @api_key_uri = 'ticket=' << ENV['CC_TOKEN']
  @api_licitaciones_uri = 'http://api.mercadopublico.cl/servicios/v1/publico/licitaciones.json?'

  def self.perform
    @licitaciones_del_dia_uri = @api_licitaciones_uri + @api_key_uri
    log_get_batch
    @response = Net::HTTP.get(URI(@licitaciones_del_dia_uri))
    # save the batch to DB
    Resque.enqueue(SaveBatchToDB, JSON.parse(@response))
    log_enqueue_batch
    @listado = JSON.parse(@response)['Listado']
    enqueue_each_licitacion(@listado)
  end

  def self.log_get_batch
    File.open("#{Rails.root}/log/get_licitaciones.log", 'a+') do |f|
      f << "Obteniendo batch a las #{Time.zone.now} \n"
    end
  end

  def self.log_enqueue_batch
    File.open("#{Rails.root}/log/get_licitaciones.log", 'a+') do |f|
      f << "Batch encolado a las #{Time.zone.now} \n"
    end
  end

  def self.log_enqueue_get_single_licitacion(codigo_externo)
    File.open("#{Rails.root}/log/get_single_licitacion.log", 'a+') do |f|
      f << "Encolando licitacion #{codigo_externo} a las #{Time.zone.now} \n"
    end
  end

  def self.enqueue_each_licitacion(listado)
    listado.each do |licitacion|
      codigo_externo = licitacion['CodigoExterno']
      log_enqueue_get_single_licitacion(codigo_externo)
      Resque.enqueue(GetSingleLicitacion,
                     codigo_externo,
                     @licitaciones_del_dia_uri)
    end
  end
end
