class AddIndexesToResultsTable < ActiveRecord::Migration[5.0]
  def change
    execute <<-SQL
      CREATE INDEX result_nombre ON results ((value->'Listado'->0->>'Nombre'));
      CREATE INDEX result_descripcion ON results ((value->'Listado'->0->>'Descripcion'));
    SQL
  end
end
