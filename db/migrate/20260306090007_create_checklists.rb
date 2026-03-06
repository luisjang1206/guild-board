class CreateChecklists < ActiveRecord::Migration[8.1]
  def change
    create_table :checklists do |t|
      t.references :task, null: false, foreign_key: true
      t.string :content, null: false
      t.boolean :completed, default: false, null: false
      t.integer :position, null: false
      t.timestamps
    end

    add_index :checklists, [ :task_id, :position ]
  end
end
