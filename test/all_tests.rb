# Combine unit and functional tests in one run
%w(unit functional ).each do |f|
  Dir[File.dirname(__FILE__) + "/#{f}/**/*_test.rb"].each do |file|
    require file
  end
end