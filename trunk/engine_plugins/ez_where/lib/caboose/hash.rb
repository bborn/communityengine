class Hash #:nodoc:  
 
  def to_sql(param = 'AND')
    map { |key,value| key.to_s+' = '+ActiveRecord::Base.send(:sanitize, value) }.join(' '+param+' ')
  end
 
  def to_conditions(param = 'AND')
    [map { |k, v| k.to_s+' = ?' }.join(' '+param+' '), *values]
  end
  
  alias :to_sql_conditions :to_conditions
 
  def to_named_conditions(param = 'AND')
    [map { |k, v| k.to_s+' = :'+k }.join(' '+param+' '), self.symbolize_keys]
  end 
   
end