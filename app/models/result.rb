class Result < ApplicationRecord

    validates :value, presence: true
    has_many :user_results, :dependent => :delete_all
    has_many :user, :through => :user_results

    def name
        begin
            UserResult.where(user_id: current_user.id, result_id: self.id).pluck("name")
        rescue NameError
            if Rails.env == "development"
                UserResult.where(result_id: self.id).pluck("name")
            else
                return "No se encontró usuario o resultado"
            end
        end
    end

    def history
        codigo_externo = self.value["Listado"][0]["CodigoExterno"]
        Result.where("value -> 'Listado' -> 0 -> 'CodigoExterno' = ?", codigo_externo.to_json)
              .order(:created_at)
    end

end
