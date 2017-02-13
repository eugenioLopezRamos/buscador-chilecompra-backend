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
        tuples = connection.execute('SELECT DISTINCT "results"."value"::json#>>\'{Listado,0,CodigoExterno}\' FROM "results"')
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
        codigo_externo = self.value["Listado"][0]["CodigoExterno"]
        Result.where("value -> 'Listado' -> 0 -> 'CodigoExterno' = ?", codigo_externo.to_json)
              .order(:created_at)
    end

    def codigo_externo
        self.value["Listado"][0]["CodigoExterno"]
    end

    def self.last_per_codigo_externo
        codigos = self.get_all_unique_codigo_externo
        last_codigos = Array.new
        codigos.each do |codigo|
            last_codigos.push(Result.where("value -> 'Listado' -> 0 ->> 'CodigoExterno' = ?", codigo).last)
        end
        last_codigos
    end

    def self.latest_entry_per_codigo_externo(start_day, end_day)

        connection = ActiveRecord::Base.connection
        result_ids = Array.new

        # Gets results id by codigo externo where updated_at is the greatest
        # (In simpler words, gets the last DB record entry per Codigo Externo between dates  start_day("YYYY-MM-DD"), end_day) 
        
        #TODO: See if its possible to structure this query in a way that is cacheable with redis
        #TODO: Although the parameters are checked before_action for the correct format
        # (date must be UNIX epoch format, so an integer) its probably a good idea to 
        # add a call to .sanitize_sql_for_conditions
        # Like this: ActiveRecord::Base.send(:sanitize_sql_for_conditions, 'I"m" a cool guy')
        # => "I\"m\" a cool guy"
        start = self.send(:sanitize_sql_for_conditions, start_day)
        finish = self.send(:sanitize_sql_for_conditions, end_day)

        unique = connection.execute(
        "SELECT id FROM (
            SELECT id, updated_at,
                dense_rank() OVER (
                    PARTITION BY value -> 'Listado' -> 0 -> 'CodigoExterno'
                    ORDER BY updated_at DESC
                    ) as by_updated_at
            FROM results
            WHERE updated_at > '#{start}'
            AND updated_at <= '#{finish}'
        ) as q
        WHERE by_updated_at < 2"
        )

        unique.each do |hash|
            hash.each_pair {|key, value| result_ids.push value }
        end

        result_ids
    end

end
