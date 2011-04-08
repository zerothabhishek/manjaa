class CreateSetupStatuses < ActiveRecord::Migration
  def self.up
    create_table :setup_statuses do |t|
      t.boolean :site_initialized, :default => false
      t.boolean :github_username_identified, :default => false
      t.boolean :site_repo_created, :default => false
      t.boolean :public_key_uploaded, :default => false
      t.boolean :site_remote_set, :default => false
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :setup_statuses
  end
end
