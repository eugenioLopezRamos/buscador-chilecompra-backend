class SaveSingleLicitacionToDB
    @queue = :save_to_db

    def self.perform(licitacion)
        datos_lic = licitacion["Listado"]
        result = Result.create(value: licitacion)
        if result.save
            File.open("#{Rails.root}/log/save_to_db.log", "a+"){|f| f << "Exito: Licitacion #{datos_lic[0]['CodigoExterno']} a las #{Time.now()} \n" }
        else
            File.open("#{Rails.root}/log/save_to_db.log", "a+"){|f| f << "Fallo: Licitacion #{datos_lic[0]['CodigoExterno']} a las #{Time.now()} \n" }          
        end
    end
end