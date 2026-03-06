# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_06_104900) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "activity_logs", force: :cascade do |t|
    t.string "action", null: false
    t.string "actor_id", null: false
    t.string "actor_type", null: false
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}
    t.bigint "project_id", null: false
    t.bigint "task_id"
    t.index ["metadata"], name: "index_activity_logs_on_metadata", using: :gin
    t.index ["project_id"], name: "index_activity_logs_on_project_id"
    t.index ["task_id"], name: "index_activity_logs_on_task_id"
  end

  create_table "board_columns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", null: false
    t.bigint "project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "position"], name: "index_board_columns_on_project_id_and_position"
    t.index ["project_id"], name: "index_board_columns_on_project_id"
  end

  create_table "checklists", force: :cascade do |t|
    t.boolean "completed", default: false, null: false
    t.string "content", null: false
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.bigint "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id", "position"], name: "index_checklists_on_task_id_and_position"
    t.index ["task_id"], name: "index_checklists_on_task_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string "author_id", null: false
    t.string "author_type", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.bigint "task_id", null: false
    t.index ["task_id"], name: "index_comments_on_task_id"
  end

  create_table "labels", force: :cascade do |t|
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_labels_on_project_id"
  end

  create_table "project_keys", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "key_digest", null: false
    t.string "key_prefix", null: false
    t.datetime "last_used_at"
    t.string "name", null: false
    t.jsonb "permissions", default: {}
    t.bigint "project_id", null: false
    t.index ["key_prefix"], name: "index_project_keys_on_key_prefix", unique: true
    t.index ["permissions"], name: "index_project_keys_on_permissions", using: :gin
    t.index ["project_id"], name: "index_project_keys_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "task_labels", force: :cascade do |t|
    t.bigint "label_id", null: false
    t.bigint "task_id", null: false
    t.index ["label_id"], name: "index_task_labels_on_label_id"
    t.index ["task_id", "label_id"], name: "index_task_labels_on_task_id_and_label_id", unique: true
    t.index ["task_id"], name: "index_task_labels_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "board_column_id", null: false
    t.datetime "created_at", null: false
    t.string "creator_id", null: false
    t.string "creator_type", null: false
    t.datetime "deleted_at"
    t.text "description"
    t.integer "position", null: false
    t.integer "priority", default: 0, null: false
    t.bigint "project_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["board_column_id", "position"], name: "index_tasks_on_board_column_id_and_position"
    t.index ["board_column_id"], name: "index_tasks_on_board_column_id"
    t.index ["id"], name: "index_tasks_active", where: "(deleted_at IS NULL)"
    t.index ["project_id"], name: "index_tasks_on_project_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "activity_logs", "projects"
  add_foreign_key "activity_logs", "tasks"
  add_foreign_key "board_columns", "projects"
  add_foreign_key "checklists", "tasks"
  add_foreign_key "comments", "tasks"
  add_foreign_key "labels", "projects"
  add_foreign_key "project_keys", "projects"
  add_foreign_key "projects", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "task_labels", "labels"
  add_foreign_key "task_labels", "tasks"
  add_foreign_key "tasks", "board_columns"
  add_foreign_key "tasks", "projects"
end
