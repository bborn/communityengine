class RemoveContests < ActiveRecord::Migration
  def up
    drop_table :contests
  end

  def down
    raise ActiveRecord::IrreversibleMigration  
  end
end
