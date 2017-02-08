module ApplicationHelper


  def json_message_to_frontend(info: nil, errors: nil, extra: {})
    hsh = {"message": {"info": info, "errors": errors}}
    message = hsh[:message]
    #delete nil value keys
    message.delete_if {|key, value| message[key].nil? }

    if extra.keys.empty?
      return hsh
    end

    extra.each_pair do |key, value|
      hsh[key] = value
    end

    hsh
  end

  def is_integer?(string)
    Integer(string) 
    rescue ArgumentError
      false
    rescue TypeError
      false
  end

  def is_boolean?(value)
    [true, "true", false, "false"].include? value
  end





end

