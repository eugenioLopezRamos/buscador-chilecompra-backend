class SaveSingleLicitacionToDB
  @queue = :save_to_db

  def self.perform(licitacion)
    datos_lic = licitacion["Listado"]
    append_log_save_attempt(datos_lic[0]['CodigoExterno'])    

    result = Result.create(value: licitacion)
    codigo_externo = @lic["Listado"][0]["CodigoExterno"]

    @latest_current_result_value = Result.where("value -> 'Listado' -> 0 ->> 'CodigoExterno' = ?", codigo_externo).last.value
    #TODO: Make it so If licitacion is unchanged, instead of creating a new record, update the "updated_at"
    # column on the current record
    if result.save
      append_log_save_success(datos_lic[0]['CodigoExterno'])
      if @latest_current_result
        check_if_unchanged(@latest_current_result_value, licitacion, codigo_externo)
      end

    else 
      append_log_save_failure(datos_lic[0]['CodigoExterno'])
    end
  end

  def self.check_if_unchanged(latest_result, previous_latest_result, codigo_externo)
    #Delete key "FechaCreacion" - It's not an important difference. We only care about the licitacion differences, not 
    # about when the record was created
    latest = latest_result.deep_dup
    latest.delete_if {|key| key == "FechaCreacion"}

    previous = previous_latest_result.deep_dup
    previous.delete_if {|key| key == "FechaCreacion"}

    if previous != latest
      Resque.enqueue(AddLicitacionChangeToUserNotifications, codigo_externo)
    end

  end

  def self.append_log_save_attempt(codigo)
    File.open("#{Rails.root}/log/save_to_db.log", "a+"){|f| f << "Intentando guardar #{codigo} a las #{Time.now()} \n" }
  end

  def self.append_log_save_success(codigo)
    File.open("#{Rails.root}/log/save_to_db.log", "a+"){|f| f << "Exito: Licitacion #{codigo} a las #{Time.now()} \n" }
  end

  def self.append_log_save_failure(codigo)
    File.open("#{Rails.root}/log/save_to_db.log", "a+"){|f| f << "Fallo: Licitacion #{codigo} a las #{Time.now()} \n" }  
  end




end