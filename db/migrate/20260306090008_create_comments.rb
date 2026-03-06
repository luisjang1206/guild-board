class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :task, null: false, foreign_key: true
      t.string :author_type, null: false
      t.string :author_id, null: false
      t.text :content, null: false
      t.datetime :created_at, null: false
    end
  end
end
