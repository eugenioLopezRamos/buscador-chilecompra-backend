# Helper methods for LicitacionDataFilters
module ResultsQueryHelper
  def default_dates
    {
      start_date: transform_date_format(Time.zone.now.to_i * 1000),
      end_date: transform_date_format(Time.zone.now.to_i * 1000 +
                                      day_in_milliseconds)
    }
  end

  def palabras_clave_query_base
    ->(field_name) { return "LOWER(value -> 'Listado' -> 0 ->> #{ActiveRecord::Base.connection.quote(field_name)}) LIKE LOWER(?)" }
  end

  def get_json_param_routes(param_data)
    {
      codigoLicitacion: ["value -> 'Listado' -> 0 ->> 'CodigoExterno' = ? ", param_data['codigoLicitacion']],
      estadoLicitacion: ["value -> 'Listado' -> 0 ->> 'CodigoEstado' = ? ", param_data['estadoLicitacion']],
      organismoPublico: ["value -> 'Listado' -> 0 -> 'Comprador' ->> 'CodigoOrganismo' = ? ", param_data['organismoPublico']],
      rutProveedor: ["value -> 'Listado' -> 0 -> 'Items' -> 'Listado' -> 0 -> 'Adjudicacion' ->> 'RutProveedor' = ? ", param_data['rutProveedor']]
    }
  end
end
