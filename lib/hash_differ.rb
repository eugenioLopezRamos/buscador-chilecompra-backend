module HashDiffer

  def self.hd
    first = second = Result.where("value -> 'Listado' -> 0 ->> 'CodigoExterno' = ?", "1272-14-LQ16").first
    second = Result.where("value -> 'Listado' -> 0 ->> 'CodigoExterno' = ?", "1272-14-LQ16").second


    f_val = first.value
    s_val = second.value



    puts f_val.keys


  end


end