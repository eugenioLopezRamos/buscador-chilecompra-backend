module ApplicationHelper

  ############### INFO LICITACIONES ##################
  ######## DESDE http://api.mercadopublico.cl/documentos/Documentaci%C3%B3n%20API%20Mercado%20Publico%20-%20Licitaciones.pdf

  def tipos_licitacion_desc
    {
      L1: "Licitación Pública menor a 100 UTM",
      LE: "Licitación Pública igual o superior a 100 UTM e inferior a 1000 UTM",
      LP: "Licitación Pública igual o superior a 1000 UTM e inferior a 2000 UTM",
      LQ: "Licitación Pública igual o superior a 2000 UTM e inferior a 5000 UTM",
      LR: "Licitación Pública igual o superior a 5000 UTM",
      E2: "Licitación Privada Menor a 100 UTM",
      CO: "Licitación Privada igual o superior a 100 UTM e inferior a 1000 UTM",
      B2: "Licitación Privada igual o superior 1000 UTM e inferior a 2000 UTM",
      H2: "Licitación Privada igual o superior a 2000 UTM e inferior a 5000 UTM",
      I2: "Licitación Privada Mayor a 5000 UTM",
      LS: "Licitación Pública Servicios personales especializados"
    }
  end

  def tipos_licitacion_rangos_UTM
    {
      L1: (0...100),
      LE: (100...1000),
      LP: (1000...2000),
      LQ: (2000...5000),
      LR: (5000...5000),
      E2: (0...100),
      CO: (100...1000),
      B2: (1000...2000),
      H2: (2000...5000),
      I2: (5000),
      LS: "N/A"
    }
  end

  def unidad_monetaria
    {
      CLP: "Peso Chileno",
      CLF: "Unidad de Fomento",
      USD: "Dólar Americano",
      UTM: "Unidad Tributaria Mensual",
      EUR: "Euro"
    }
  end

  def monto_estimado
    {
      1: "Presupuesto Disponible",
      2: "Precio Referencial",
      3: "Monto no es posible de estimar"
    }
  end

  def modalidad_de_pago
    {
      1: "Pago a 30 días",
      2: "Pago a 30, 60 y 90 días",
      3: "Pago al día",
      4: "Pago anual",
      5: "Pago bimensual",
      6: "Pago contra entrega conforme",
      7: "Pagos mensuales",
      8: "Pago por estado de avance",
      9: "Pago trimestral",
      10: "Pago a 60 dias",
    }
  end

  def unidad_tiempo_evaluacion
    {
      1: "Horas",
      2: "Días",
      3: "Semanas",
      4: "Meses",
      5: "Años"
    }
  end

  def unidad_tiempo_duracion_contrato
    {
      1: "Horas",
      2: "Días",
      3: "Semanas",
      4: "Meses",
      5: "Años"
    }
  end

  def acto_que_autoriza
    {
      1: "Autorización",
      2: "Resolución",
      3: "Acuerdo",
      4: "Decreto",
      5: "Otros"
    }
  end

  ############################ INFO ORDENES DE COMPRA ################3
  ################# SACADO DE http://api.mercadopublico.cl/documentos/Documentaci%C3%B3n%20API%20de%20Mercado%20P%C3%BAblico%20-%20%C3%93rdenes%20de%20Compra.pdf

  def tipo_orden_compra
    {
      8: "SE - Sin emisión automática",
      9: "CM - Convenio Marco"
    }
  end

  def tipo_despacho
    {
      7: "Despachar a dirección de envío",
      9: "Despachar según programa adjuntado",
      12: "Otra forma de despacho, ver instruc.",
      14: "Retiramos de su bodega",
      20: "Despacho por courier o encomienda aérea",
      21: "Despacho por courier o encomienda terrestre",
      22: "A convenir"
    }
  end

  def format_pago_orden_compra
    {
      1: "15 días contra la recepción de la factura",
      2: "30 días contra la recepción de la factura",
      39: "Otra forma de pago",
      46: "50 días contra la recepción de la factura",
      47: "60 días contra la recepción de la factura"
    }
  end

end