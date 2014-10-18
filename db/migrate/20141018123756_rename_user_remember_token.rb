class RenameUserRememberToken < ActiveRecord::Migration
  def change
    remove_column :users, :remember_token
    add_column :users, :remember_digest, :string
  end
end
