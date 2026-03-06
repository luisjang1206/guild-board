class CreateBoardColumns < ActiveRecord::Migration[8.1]
  def change
    create_table :board_columns do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false
      t.timestamps
    end

    add_index :board_columns, [ :project_id, :position ]
  end
end
