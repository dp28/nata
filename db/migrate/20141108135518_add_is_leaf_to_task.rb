class AddIsLeafToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :is_leaf, :boolean, default: true
  end
end
