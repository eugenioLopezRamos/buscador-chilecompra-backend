
[1mFrom:[0m /home/eugenio/workspaces/cc/app/models/user.rb @ line 41 User#subscribe_to_result:

    [1;34m35[0m: [32mdef[0m [1;34msubscribe_to_result[0m(result_id, name)
    [1;34m36[0m:   [1;34m# Search if the user is already subscribed to result_id[0m
    [1;34m37[0m:   @codigo_externo = [1;34;4mResult[0m.find(result_id).value[[31m[1;31m"[0m[31mListado[1;31m"[0m[31m[0m][[1;34m0[0m][[31m[1;31m"[0m[31mCodigoExterno[1;31m"[0m[31m[0m]
    [1;34m38[0m:   @codigo_externo_all_ids = [1;34;4mResult[0m.where([31m[1;31m"[0m[31mvalue -> 'Listado' -> 0 ->> 'CodigoExterno' = ?[1;31m"[0m[31m[0m, @codigo_externo).pluck([31m[1;31m"[0m[31mid[1;31m"[0m[31m[0m)
    [1;34m39[0m:   [1;34m#Returns the id of the results with CodigoExterno == @codigo_externo[0m
    [1;34m40[0m:   @user_subscriptions_codigos_externos = [1;36mself[0m.subscriptions.values.select {|value| @codigo_externo_all_ids.include? value}
 => [1;34m41[0m:   binding.pry
    [1;34m42[0m:   [32mif[0m @user_subscriptions_codigos_externos.include? @codigo_externo
    [1;34m43[0m:     @nombre_suscripcion = [1;36mself[0m.subscriptions.key(result_id)
    [1;34m44[0m:     raise [1;34;4mActiveRecord[0m::[1;34;4mRecordInvalid[0m[1;34m# estas suscrito a la licitacion codigo #{@codigo_externo} (Nombre suscripción: #{@nombre_suscripcion})"[0m
    [1;34m45[0m: 
    [1;34m46[0m:   [32melse[0m
    [1;34m47[0m:     [1;34;4mUserResult[0m.create([35muser_id[0m: [1;36mself[0m.id, [35mresult_id[0m: result_id, [35msubscribed[0m: [1;36mtrue[0m, [35msubscription_name[0m: name)
    [1;34m48[0m:   [32mend[0m
    [1;34m49[0m: 
    [1;34m50[0m: 
    [1;34m51[0m: 
    [1;34m52[0m: [32mend[0m

