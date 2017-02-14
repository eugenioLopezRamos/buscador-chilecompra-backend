class GetSingleLicitacion

  @queue = :licitaciones

  def self.perform(codigo, uri)
    @uri = uri + "&Codigo=" + codigo

    #The chilecompra API throttles, max is 1 request per 2 seconds.
    sleep(2)

    @lic = JSON.parse(Net::HTTP.get(URI(@uri)))
    Resque.enqueue(SaveSingleLicitacionToDB, @lic)
  end

end