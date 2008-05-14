class AddPublishedAsTo<%= publishing_class.pluralize %> < ActiveRecord::Migration

  # Add the new tables.
  def self.up
    add_column :<%= publishing_table_name %>, :published_as, :string, :limit => 16, :default => 'draft'
  end

  # Remove the tables.
  def self.down
    remove_column :<%= publishing_table_name %>, :published_as
  end

end
