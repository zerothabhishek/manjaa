class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :password_digest
    end
  end

  def self.down
    drop_table :users
  end
end
