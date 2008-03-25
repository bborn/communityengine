class CreateLoginSlug < ActiveRecord::Migration
  def self.up
    add_column "users", "login_slug", :string
    User.find(:all).each do |user|
      user.login_slug = user.generate_login_slug
      user.save!
    end
  end

  def self.down
    remove_column "users", "login_slug"
  end
end
