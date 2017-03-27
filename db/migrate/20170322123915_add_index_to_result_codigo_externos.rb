class AddIndexToResultCodigoExternos < ActiveRecord::Migration[5.0]
  def change
    execute <<-SQL
      CREATE INDEX result_codigo_externo ON results ((value->'Listado'->0->>'CodigoExterno'));
    SQL
  end
end
