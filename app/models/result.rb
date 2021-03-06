# Data that is fetched from the chilecompra API
class Result < ApplicationRecord
  # Name of the Redis set for unique codigo_externo s
  CODIGOS_EXTERNOS_SET = :codigos_externos

  validates :value, presence: true
  has_many :user_results, dependent: :delete_all
  has_many :user, through: :user_results

  def self.all_unique_codigo_externo_from_db
    connection = ActiveRecord::Base.connection
    # a tuple = key value pair such as {"\"column\"": "\"111-AAA-BBB\""}
    # tuples = array of all unique CodigoExternos
    tuples = connection.execute('SELECT DISTINCT "results"."value"::json#>>\'{Listado,0,CodigoExterno}\' AS "codigo_externo" FROM "results"')
    codigos = []

    tuples.each do |tuple|
      tuple.each_pair do |_key, value|
        codigos.push value
      end
    end
    codigos
  end

  def self.get_all_unique_codigo_externo(force_db: false)
    cached_codigos_externos = Redis.current.smembers(CODIGOS_EXTERNOS_SET)

    return cached_codigos_externos unless cached_codigos_externos.empty? || force_db == true
    all_unique_codigo_externo_from_db
  end

  def self.set_all_unique_codigo_externo_to_redis
    codigos = all_unique_codigo_externo_from_db
    codigos.each do |codigo|
      Redis.current.SADD(CODIGOS_EXTERNOS_SET, codigo)
    end
  end

  def history
    Result.where("value -> 'Listado' -> 0 ->> 'CodigoExterno' = ?", codigo_externo)
          .order(:created_at)
  end

  def codigo_externo
    value['Listado'][0]['CodigoExterno']
  end

  class << self
    def last_per_codigo_externo
      codigos = Rails.env != 'test' ? get_all_unique_codigo_externo : get_all_unique_codigo_externo(force_db: true)
      last_codigos = []
      codigos.each do |codigo|
        last_codigos.push(Result.where("value -> 'Listado' -> 0 ->> 'CodigoExterno' = ?", codigo).last)
      end
      last_codigos
    end

    # as of whenever the method is called
    def all_with_codigo_externo(codigo_externo)
      Result.where("value -> 'Listado' -> 0 ->> 'CodigoExterno' = ?", codigo_externo)
    end

    def get_latest_results_per_ids(start_date, end_date)
      latest_result_ids_per_codigo_externo = Result.latest_entry_per_codigo_externo(start_date, end_date)
      Result.filter_by_ids(latest_result_ids_per_codigo_externo)
    end

    # Has a date range
    def latest_entry_per_codigo_externo(start_day, end_day)
      connection = ActiveRecord::Base.connection
      # Gets results id by codigo externo where updated_at is the greatest
      # (In simpler words, gets the last DB record entry per Codigo Externo between dates  start_day("YYYY-MM-DD"), end_day)

      # TODO: See if its possible to structure this query in a way that is cacheable with redis
      # TODO: Although the parameters are checked before_action for the correct format
      # (date must be UNIX epoch format, so an integer and transformation to string is done where
      # after checking that what we received is an int) its probably a good idea to
      # add a call to .quote
      # Like this: ActiveRecord::Base.connection.quote(value)

      # TODO: See if its convenient to use ApplicationHelper#integer? here
      start_date = connection.quote(start_day)
      finish_date = connection.quote(end_day)
      unique = group_rank_and_filter_sql_statement(connection, start_date,
                                                   finish_date)
      unique.map { |hsh| hsh['id'] }
    end

    # rubocop:disable Metrics/MethodLength
    # Can't currently find a way to make this smaller w/o losing readability
    def group_rank_and_filter_sql_statement(connection, start_date, finish_date)
      # 1. Takes all CodigoExterno with FechaCreacion >= start_date && 
      #    FechaCreacion <= finish_date
      # 2. Ranks them (densely: https://www.postgresql.org/docs/9.6/static/functions-window.html)
      # 3. Sorts the by FechaCreacion DESC (that is, newest to oldest)
      # 4. Returns the newest one (The first ranked one, hence by_fecha_creacion < 2)
      # 5. Sorts by id.
      connection.execute(
        "SELECT id FROM (
            SELECT id, updated_at,
                dense_rank() OVER (
                    PARTITION BY value -> 'Listado' -> 0 -> 'CodigoExterno'
                    ORDER BY value ->> 'FechaCreacion' DESC) as by_fecha_creacion
            FROM results
            WHERE f_cast_isots(value ->> 'FechaCreacion'::text) >= #{start_date}
            AND f_cast_isots(value ->> 'FechaCreacion'::text) <= #{finish_date}
        ) as q WHERE by_fecha_creacion < 2
        ORDER BY id"
      )
    end
    # rubocop:enable Metrics/MethodLength

    def filter_by_ids(ids)
      Result.where("results.id IN(SELECT(UNNEST(array#{ids}::integer[])))")
    end
  end
end
