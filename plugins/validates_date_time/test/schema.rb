ActiveRecord::Schema.define :version => 0 do
  create_table :people, :force => true do |t|
    t.column :date_of_birth,          :date
    t.column :date_of_death,          :date
    
    t.column :date_of_arrival,        :date
    t.column :date_of_departure,      :date
  
    t.column :time_of_birth,          :time
    t.column :time_of_death,          :time
    
    t.column :date_and_time_of_birth, :datetime
    
    t.column :required_date,          :date
  end
end
