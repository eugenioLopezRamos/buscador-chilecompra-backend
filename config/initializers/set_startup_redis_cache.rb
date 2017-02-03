

  #Stores all unique codigo_externo to redis on app start
  Result.set_all_unique_codigo_externo_to_redis
  #Stores all organismos publicos data. get => Redis.current.hgetall("organismos_publics")
  # Stores all estados_licitacion data. get => Redis.current.hgetall("estados_licitacion")
  CacheLicitacionesData.perform