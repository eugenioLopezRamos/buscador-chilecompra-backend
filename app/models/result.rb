class Result < ApplicationRecord
    #Name of the Redis set for unique codigo_externo s
    CODIGOS_EXTERNOS_SET = :codigos_externos
    
    validates :value, presence: true
    has_many :user_results, :dependent => :delete_all
    has_many :user, :through => :user_results
    
    def self.get_all_unique_codigo_externo_from_db
        connection = ActiveRecord::Base.connection
        #a tuple = key value pair such as {"\"column\"": "\"111-AAA-BBB\""}
        # tuples = array of all unique CodigoExternos 
        tuples = connection.execute('SELECT DISTINCT "results"."value"::json#>>\'{Listado,0,CodigoExterno}\' AS "codigo_externo" FROM "results"')
        codigos = Array.new

        tuples.each do |tuple|
            tuple.each_pair do |key, value|
                codigos.push value
            end
        end
        codigos
    end

    def self.get_all_unique_codigo_externo(force_db: false)
        cached_codigos_externos = Redis.current.smembers(CODIGOS_EXTERNOS_SET)

        return cached_codigos_externos unless cached_codigos_externos.empty? || force_db == true
        self.get_all_unique_codigo_externo_from_db
    end
    
    def self.set_all_unique_codigo_externo_to_redis
        codigos = self.get_all_unique_codigo_externo_from_db
        codigos.each do |codigo|
            Redis.current.SADD(CODIGOS_EXTERNOS_SET, codigo)
        end
    end

    def history
        Result.where("value -> 'Listado' -> 0 -> 'CodigoExterno' = ?", self.codigo_externo.to_json)
              .order(:created_at)
    end

    def codigo_externo
        self.value["Listado"][0]["CodigoExterno"]
    end

    def self.last_per_codigo_externo
        Rails.env != "test" ? codigos = self.get_all_unique_codigo_externo : codigos = self.get_all_unique_codigo_externo(force_db: true)
        last_codigos = Array.new
        codigos.each do |codigo|
            last_codigos.push(Result.where("value -> 'Listado' -> 0 ->> 'CodigoExterno' = ?", codigo).last)
        end
        last_codigos
    end
    # as of whenever the method is called
    def self.all_with_codigo_externo(codigo_externo)
        Result.where("value -> 'Listado' -> 0 ->> 'CodigoExterno' = ?", codigo_externo)
    end

    # Has a date range
    def self.latest_entry_per_codigo_externo(start_day, end_day)

        connection = ActiveRecord::Base.connection
        result_ids = Array.new

        # Gets results id by codigo externo where updated_at is the greatest
        # (In simpler words, gets the last DB record entry per Codigo Externo between dates  start_day("YYYY-MM-DD"), end_day) 
        
        #TODO: See if its possible to structure this query in a way that is cacheable with redis
        #TODO: Although the parameters are checked before_action for the correct format
        # (date must be UNIX epoch format, so an integer and transformation to string is done where
        # after checking that what we received is an int) its probably a good idea to 
        # add a call to .quote
        # Like this: ActiveRecord::Base.connection.quote(value)

        #TODO: See if its convenient to use ApplicationHelper#is_integer? here
        start_date = connection.quote(start_day)
        finish_date = connection.quote(end_day)
 
    #    debugger
        unique = connection.execute(
        "SELECT id FROM (
            SELECT id, updated_at,
                dense_rank() OVER (
                    PARTITION BY value -> 'Listado' -> 0 -> 'CodigoExterno'
                    ORDER BY to_date(value ->> 'FechaCreacion', 'YYYY-MM-DD') DESC
                    ) as by_fecha_creacion
            FROM results
            WHERE to_date(value ->> 'FechaCreacion', 'YYYY-MM-DD') > #{start_date}
            AND to_date(value ->> 'FechaCreacion', 'YYYY-MM-DD') <= #{finish_date}
        ) as q
        WHERE by_fecha_creacion < 2"
        )

        unique.each do |hash|
            hash.each_pair {|key, value| result_ids.push value }
        end

        result_ids
    end

end
