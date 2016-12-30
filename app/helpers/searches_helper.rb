module SearchesHelper

  def create_search(search)
    @messages = Hash.new
    #a searchName is given
  #   if !search[:searchName].empty?
  #     begin
  #       new_search = current_user.searches.create(value: search, name: search[:searchName])
  #       if new_search_save
  #         @messages["info"] = "Resultado guardado exitosamente"
  #      
  #     rescue ActiveRecord::RecordNotUnique
  #       @messages["error"] = "Nombre de resultado duplicado, por favor elige otro"
  #     end

  #   else #when no :searchName is given
  #     begin
  #       new_search = current_user.searches.create(value: search)
  #       if new_search_save
  #         @messages["info"] = "Resultado guardado exitosamente"
  #       end 
  #     rescue ActiveRecord::RecordNotUnique
  #       @messages["error"] = "Nombre de resultado duplicado, por favor elige otro"
  #     end
  # end
    @messages
  end
  
    private

    def to_send(search)
      if search[:searchResults]
        ["value = ?", 
      end
    end





end