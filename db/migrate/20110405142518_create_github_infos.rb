class CreateGithubInfos < ActiveRecord::Migration
  def self.up
    create_table :github_infos do |t|
      t.string :github_username
      t.string :access_token
      t.string :access_code
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :github_infos
  end
end
