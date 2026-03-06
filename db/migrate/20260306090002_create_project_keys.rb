class CreateProjectKeys < ActiveRecord::Migration[8.1]
  def change
    create_table :project_keys do |t|
      t.references :project, null: false, foreign_key: true
      t.string :key_digest, null: false
      t.string :key_prefix, null: false
      t.string :name, null: false
      t.jsonb :permissions, default: {}
      t.boolean :active, default: true, null: false
      t.datetime :last_used_at
      t.datetime :created_at, null: false
    end

    add_index :project_keys, :key_prefix, unique: true
    add_index :project_keys, :permissions, using: :gin
  end
end
