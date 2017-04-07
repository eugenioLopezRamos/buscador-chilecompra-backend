module GetLicitacionesMock
  def self.mock_lista_licitaciones
    [
      {
        CodigoEstado: 6,
        CodigoExterno: '1002-7-LE17',
        FechaCierre: '2017-03-13T15:29:00',
        Nombre: 'SERVICIO DE ASEO OFICINAS DIRECCION DE VIALIDAD'
      },
      {
        CodigoEstado: 5,
        CodigoExterno: '1004-12-L117',
        FechaCierre: '2017-03-20T15:40:00',
        Nombre: 'SUMINISTRO DE LEÑA PARA VIALIDAD CHILE CHICO'
      }
    ]
  end

  def self.mock_chilecompra_response
    {
      "Cantidad": 2,
      "FechaCreacion": '2017-03-13T15:30:24.913',
      "Version": 'v1',
      "Listado": mock_lista_licitaciones
    }
  end
end
