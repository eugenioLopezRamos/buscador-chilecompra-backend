# Saves a licitacion's data to the database. Additionally, this job checks if it
# has changed, which triggers the enqueing (sp?) of
# AddLicitacionChangeToUserNotifications job.
class SaveSingleLicitacionToDB
  @queue = :save_to_db

  def self.perform(licitacion)
    licitacion_data = licitacion['Listado']
    return if licitacion_data.empty?
    codigo_externo = licitacion_data[0]['CodigoExterno']
    log_save_attempt(codigo_externo)
    @previous_result_value = self.get_previous_result_value(codigo_externo)
    # TODO: Make it so If licitacion is unchanged, instead of creating a new
    # record, update the "updated_at" column on the current record?
    result = Result.create(value: licitacion)
    after_create_result_actions(result,
                                @previous_result_value,
                                codigo_externo,
                                licitacion)
  end

  def self.check_if_unchanged(latest_result, prev_latest_result, codigo_externo)
    # Delete key "FechaCreacion" - It's not an important difference.
    # We only care about the licitacion differences, not about when the record
    # was created
    latest = self.remove_fecha_creacion(latest_result)
    previous_latest = self.remove_fecha_creacion(prev_latest_result)

    if latest != previous_latest
      Resque.enqueue(AddLicitacionChangeToUserNotifications, codigo_externo)
    end
  end

  def self.after_create_result_actions(result, prev_result_value, cod_externo,
                                       licitacion)
    # TODO: Maybe see if this can be moved to Result model?
    if result.save
      log_save_success(cod_externo)
      # if @previous_result_value = nil -> can't have been subscribed
      # -> no notifs to create
      if !@previous_result_value.nil?
        check_if_unchanged(licitacion, prev_result_value, cod_externo)
      end
    else
      log_save_failure(cod_externo)
    end
  end

  def self.remove_fecha_creacion(hsh)
    without_fecha_creacion = hsh.deep_dup
    without_fecha_creacion.delete_if {|key| key == 'FechaCreacion'}
    without_fecha_creacion
  end

  def self.get_previous_result_value(codigo_externo)
    previous_result_value = nil
    query_string = "value -> 'Listado' -> 0 ->> 'CodigoExterno' = ?"
    last_result = Result.where(query_string, codigo_externo).last

    unless last_result.nil?
      previous_result_value = last_result.value
    end
    previous_result_value
  end

  def self.log_save_attempt(codigo)
    File.open("#{Rails.root}/log/save_to_db.log", 'a+') do |f|
      f << "Intentando guardar #{codigo} a las #{Time.zone.now} \n"
    end
  end

  def self.log_save_success(codigo)
    File.open("#{Rails.root}/log/save_to_db.log", 'a+') do |f|
      f << "Exito: Licitacion #{codigo} a las #{Time.zone.now} \n"
    end
  end

  def self.log_save_failure(codigo)
    File.open("#{Rails.root}/log/save_to_db.log", 'a+') do |f|
      f << "Fallo: Licitacion #{codigo} a las #{Time.zone.now} \n"
    end
  end
end
