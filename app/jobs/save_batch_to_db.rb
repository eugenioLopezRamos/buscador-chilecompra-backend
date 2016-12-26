class SaveBatchToDB
    @queue = :save_to_db

    def self.perform(batch)

        batch = Batch.create(value: batch)
        if batch.save
            File.open("#{Rails.root}/log/save_batch_to_db.log", "a+"){|f| f << "Exito: Lote guardado con éxito a las #{Time.now()} \n" }
        else
            File.open("#{Rails.root}/log/save_batch_to_db.log", "a+"){|f| f << "Fallo: Error al guardar lote a las #{Time.now()} \n" }          
        end
    end
end