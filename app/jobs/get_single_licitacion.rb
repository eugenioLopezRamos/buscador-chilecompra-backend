class GetSingleLicitacion

    @queue = :licitaciones

    def self.perform(codigo, uri)
        @uri = uri + "&Codigo=" + codigo

        #The chilecompra API throttles.
        sleep(2)

        @lic = JSON.parse(Net::HTTP.get(URI(@uri)))

        @lic_codigo_externo = @lic["Listado"][0]["CodigoExterno"]

        @latest_current_result = Result.where("value -> 'Listado' -> 0 ->> 'CodigoExterno' = ?", @lic_codigo_externo).last

        if @latest_current_result
            #Delete key "FechaCreacion" - It's not an important difference. We only care about the licitacion differences, not 
            # about when the record was created
            @latest_current_result.value.delete_if {|key| key == "FechaCreacion"}
            @compare_lic = @lic.deep_dup
            @compare_lic.delete_if {|key| key == "FechaCreacion"}

            if @compare_lic != @latest_current_result.value
                Resque.enqueue(AddResultChangeToUserNotifications, @lic_codigo_externo)
            end
        end

        Resque.enqueue(SaveSingleLicitacionToDB, @lic)
    end

end