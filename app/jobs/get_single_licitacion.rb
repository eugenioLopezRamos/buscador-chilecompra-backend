class GetSingleLicitacion

    @queue = :licitaciones

    def self.perform(codigo, uri)
        @uri = uri + "&Codigo=" + codigo

        #The chilecompra API throttles.
        sleep(2)

        @lic = JSON.parse(Net::HTTP.get(URI(@uri)))
        #With this we can already fetch data from the API, next step is saving it to the DB, which will be done with another job (SaveSingleLicitacionToDB)
        # if JSON.parse(@lic)["Codigo"]
        #     puts "ERROR #{@lic}"
        # else 
        #     puts "lic #{JSON.parse(@lic)['Listado'][0]['CodigoExterno']} nombre #{JSON.parse(@lic)['Listado'][0]['Nombre']}"
        # end

        Resque.enqueue(SaveSingleLicitacionToDB, @lic)
    end

end

