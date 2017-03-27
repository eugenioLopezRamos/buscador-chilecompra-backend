class AddFechaCreacionIndexToResults < ActiveRecord::Migration[5.0]
  def change
    #http://stackoverflow.com/questions/29757374/create-timestamp-index-from-json-on-postgresql#comment47648833_29757374 
    #Thanks!
    execute <<-SQL
    CREATE OR REPLACE FUNCTION f_cast_isots(text)
      RETURNS timestamptz AS
      $$SELECT to_timestamp($1, 'YYYY-MM-DD')$$ 
        LANGUAGE sql IMMUTABLE;

      CREATE INDEX fecha_creacion_json ON results (f_cast_isots(value->>'FechaCreacion'));
    SQL
  end
end
#TODO: Migrate this tomorrow

# cl timezone -> America/Santiago - Since these date come from chilecompra, we just take them as Santiago timezone
   