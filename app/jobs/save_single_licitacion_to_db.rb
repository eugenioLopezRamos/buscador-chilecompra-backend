class SaveSingleLicitacionToDB

    @queue = :save_to_db

    def self.perform(licitacion)

        puts "LICITACION A LA DB! #{licitacion}"

    end

end