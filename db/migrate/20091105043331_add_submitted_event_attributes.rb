class AddSubmittedEventAttributes < ActiveRecord::Migration
  def self.up
    add_column :events, :submitted, :boolean, :default => false
    add_column :events, :approved, :boolean, :default => false
    add_column :events, :email, :string, :limit => 255
    add_column :events, :created_at, :timestamp
  end

  def self.down
    remove_column :events, :submitted
    remove_column :events, :approved
    remove_column :events, :email
    remove_column :events, :created_at
  end
end
