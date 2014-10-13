class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.text :content
      t.integer :user_id
      t.integer :parent_id
      t.boolean :completed

      t.timestamps
    end
    add_index :tasks, [:user_id, :created_at, :parent_id]
  end
end
