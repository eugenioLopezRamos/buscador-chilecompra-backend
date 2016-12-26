class GetSingleLicitacion

    @queue = :licitaciones

    def self.perform(codigo, uri)
        @uri = uri + "&Codigo=" + codigo

        #The chilecompra API throttles.
        sleep(2)

        @lic = JSON.parse(Net::HTTP.get(URI(@uri)))

        Resque.enqueue(SaveSingleLicitacionToDB, @lic)
    end

end