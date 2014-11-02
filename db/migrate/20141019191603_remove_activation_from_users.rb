class RemoveActivationFromUsers < ActiveRecord::Migration
  def change
    [:activation_digest, :activated, :activated_at].each { | column| remove_column :users, column }
  end
end
