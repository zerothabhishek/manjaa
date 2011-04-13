class AddPublishStatusToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :publish_status, :string, :default => ""
  end

  def self.down
    remove_column :posts, :publish_status
  end
end
