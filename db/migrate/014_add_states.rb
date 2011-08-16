class AddStates < ActiveRecord::Migration
  def self.up
    %w(AL AK AZ AR CA CO CT DE DC FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY).each do |s|
      State.new(:name => s).save
    end
  end

  def self.down
    State.destroy_all
  end
end
