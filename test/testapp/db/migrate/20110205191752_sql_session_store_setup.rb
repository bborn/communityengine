class SqlSessionStoreSetup < ActiveRecord::Migration

  # SqlSessionStore is no longer included as the default session store.
  # If you want to use it, you'll need to install the plugin and run the appropraite migration and environment setup.
  # class Session < ActiveRecord::Base; end
  # 
  # def self.up
  #   
  #   c = ActiveRecord::Base.connection
  #   if c.tables.include?('sessions')
  #     if (columns = Session.column_names).include?('sessid')
  #       remove_index 'sessions', 'sessid'
  #       remove_column 'sessions', 'sessid'
  #       add_column 'sessions', 'session_id', :string
  #     else
  #       add_column 'sessions', 'session_id', :string unless columns.include?('session_id')
  #       add_column 'sessions', 'data', :text unless columns.include?('data')
  # 
  #       remove_column 'sessions', 'created_on' if columns.include?('created_on')
  #       add_column 'sessions', 'created_at', :timestamp unless columns.include?('created_at')          
  # 
  #       remove_column 'sessions', 'updated_on' if columns.include?('updated_on')
  #       add_column 'sessions', 'updated_at', :timestamp unless columns.include?('updated_at')
  #     end
  #   else
  #     create_table 'sessions', :options => 'ENGINE=MyISAM' do |t|
  #       t.column 'session_id', :string
  #       t.column 'data',       :text
  #       t.column 'created_at', :timestamp
  #       t.column 'updated_at', :timestamp
  #     end
  #     add_index 'sessions', 'session_id', :name => 'session_id_idx'
  #   end
  # end
  # 
  # def self.down
  #   raise IrreversibleMigration
  # end
end
