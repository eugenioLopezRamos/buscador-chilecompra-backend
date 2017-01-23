class Result < ApplicationRecord

    validates :value, presence: true
    has_many :user_results, :dependent => :delete_all
    has_many :user, :through => :user_results

    def history
        codigo_externo = self.value["Listado"][0]["CodigoExterno"]
        Result.where("value -> 'Listado' -> 0 -> 'CodigoExterno' = ?", codigo_externo.to_json)
              .order(:created_at)
    end

    def codigo_externo
        self.value["Listado"][0]["CodigoExterno"]
    end

end
