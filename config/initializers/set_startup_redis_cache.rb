

  #Stores all unique codigo_externo to redis on app start - Unless env is test since that stops seeds from working.
  

  if Result
    Result.set_all_unique_codigo_externo_to_redis unless Rails.env == "test"
  end

  #Stores all organismos publicos data. get => Redis.current.hgetall("organismos_publics")
  # Stores all estados_licitacion data. get => Redis.current.hgetall("estados_licitacion")
  CacheLicitacionesData.perform unless Rails.env == "test"