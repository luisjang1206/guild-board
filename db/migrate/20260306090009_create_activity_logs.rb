class CreateActivityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_logs do |t|
      t.references :project, null: false, foreign_key: true
      t.references :task, null: true, foreign_key: true
      t.string :actor_type, null: false
      t.string :actor_id, null: false
      t.string :action, null: false
      t.jsonb :changes, default: {}
      t.datetime :created_at, null: false
    end

    add_index :activity_logs, :changes, using: :gin
  end
end
