class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :project, null: false, foreign_key: true
      t.references :board_column, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :priority, default: 0, null: false
      t.integer :position, null: false
      t.string :creator_type, null: false
      t.string :creator_id, null: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :tasks, [ :board_column_id, :position ]
    add_index :tasks, :id, where: "deleted_at IS NULL", name: "index_tasks_active"
  end
end
