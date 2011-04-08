class AddSiteIdToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :site_id, :integer
  end

  def self.down
    remove_column :posts, :site_id
  end
end
