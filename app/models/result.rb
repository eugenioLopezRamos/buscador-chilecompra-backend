class Result < ApplicationRecord

    validates :value, presence: true
    has_many :user_results, :dependent => :delete_all
    has_many :user, :through => :user_results
    
    def self.all_unique_codigo_externo
        conn = ActiveRecord::Base.connection
        #a tuple = key value pair
        tuples = conn.execute('SELECT DISTINCT "results"."value"::json#>>\'{Listado,0,CodigoExterno}\' FROM "results"')
        codigos = Array.new
        tuples.each do |tuple|
            tuple.each_pair do |key, value|
                codigos.push value
            end
        end
        codigos

    end

    def history
        codigo_externo = self.value["Listado"][0]["CodigoExterno"]
        Result.where("value -> 'Listado' -> 0 -> 'CodigoExterno' = ?", codigo_externo.to_json)
              .order(:created_at)
    end

    def codigo_externo
        self.value["Listado"][0]["CodigoExterno"]
    end

end
