# Prepares parameter values so they are valid
# Eg remove "*" which is used only on the frontend to '' so it is ignored, 
# applies the current date when alwaysToToday/alwaysFromToday is checked etc
module LicitacionDataScrubber
  include ApplicationHelper

  def remove_wildcards(parameters)
    if parameters['organismoPublico'] == '*' || !parameters['organismoPublico']
      parameters['organismoPublico'] = ''
    end

    if parameters['estadoLicitacion'] == '*' || !parameters['estadoLicitacion']
      parameters['estadoLicitacion'] = ''
    end
    parameters['offset'] = 0 unless parameters['offset']
    # see what to do wth order_by....
    parameters['order_by'] = parameters['order_by']
    parameters
  end

  def dates_with_always_today(parameters)
    # If alwaysFromToday == "true" then we use defaults for BOTH dates
    return default_dates if parameters['alwaysFromToday'] == 'true'
    # if alwaysToToday, use the default only for end_date(start_date gets its entered value)
    {
      start_date: transform_date_format(parameters['startDate']),
      end_date: default_dates[:end_date]
    }
  end

  def calculate_offset(offset, results_amount, limit)
    return 0 if offset.to_i < 0
    if offset.to_i >= results_amount
      # these are integers, so the decimals are truncated -> becomes the last chunk of results
      new_offset = results_amount / limit
      new_offset *= limit
      return new_offset
    end
    offset.to_i
  end

  def create_order_by(order_by)
    # TODO: Check if vulnerable to sql injection :(
    # order_by = {fields: [...], order: "descending || ascending" }
    fields = order_by_fields(order_by[:fields])
    order_by_query = ''
    fields[0..-2].each { |field| order_by_query << " #{field} ->" }
    order_by_query << " #{fields[-1]} "
    order_by_query << 'DESC' if order_by['order'] == 'descending'
    order_by_query << 'ASC' if order_by['order'] == 'ascending'
    order_by_query
  end

  def order_by_fields(fields_array)
    return ['value'].concat RequestsController::DEFAULT_ORDER_BY_FIELD if fields_array.empty?
    fields = fields_array.map do |element|
      if integer? element
        element.to_s
      else
        ActiveRecord::Base.connection.quote(element)
      end
    end
    ['value'].concat fields
  end

  def determine_dates(parameters)
    # From the frontend dates come in unix epoch format,
    # which becomes YYYY-MM-DD  @ 00:00 AM
    # So, to get the end_date complete we need to add one more day_in_milliseconds
    # (if we want all results up to 2017-01-25, we need to set end_date to 27-01-26
    # so we'll get all results with date LESS than 2017-01-26 @ 00:00 AM

    # Javascript time is ruby time * 1000
    if parameters['alwaysFromToday'] == 'true' || parameters['alwaysToToday'] == 'true'
      return dates_with_always_today(parameters)
    end

    start_date = transform_date_format(parameters['startDate'])
    end_date_next_day = parameters['endDate'].to_i + day_in_milliseconds

    end_date = transform_date_format(end_date_next_day)

    { start_date: start_date, end_date: end_date }
  end

  def palabras_clave_to_array(parameters)
    parameters['palabrasClave'] = [] if parameters['palabrasClave'].nil? ||
                                       parameters['palabrasClave'].split(' ')
                                                                 .empty?
    unless parameters['palabrasClave'].empty?
      parameters['palabrasClave'] = parameters['palabrasClave']
                                   .split(' ')
                                   .map! { |palabra| "%#{palabra}%" }
    end
    parameters
  end

end