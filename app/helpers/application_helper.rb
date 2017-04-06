module ApplicationHelper
  def json_message_to_frontend(info: nil, errors: nil, extra: {})
    hsh = { "message": { "info": info, "errors": errors } }
    message = hsh[:message]
    # delete nil value keys
    message.delete_if { |key, _value| message[key].nil? }

    return hsh if extra.keys.empty?

    extra.each_pair do |key, value|
      hsh[key] = value
    end

    hsh
  end
  
  def day_in_milliseconds
    hours = 24
    minutes = 60
    seconds = 60
    thousand = 1000
    hours * minutes * seconds * thousand
  end

  def stringify_param_values(parameters)
    param_data = {}
    parameters.each_pair { |k, v| param_data[k] = v.to_s }
  end

  def transform_date_format(date)
    # Need to divide the MomentJS date  by 1000 to get the correct one.
    Time.at(date.to_i / 1000).strftime('%Y-%m-%d')
  end

  def is_integer?(string)
    Integer(string)
  rescue ArgumentError
    false
  rescue TypeError
    false
  end

  def is_boolean?(value)
    [true, 'true', false, 'false'].include? value
  end
end
