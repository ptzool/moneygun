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

ActiveRecord::Schema[8.0].define(version: 2025_05_23_183523) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "membership_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "task_id", null: false
    t.index ["membership_id"], name: "index_comments_on_membership_id"
    t.index ["task_id"], name: "index_comments_on_task_id"
  end

  create_table "inboxes", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "organization_id"], name: "index_inboxes_on_name_and_organization_id", unique: true
    t.index ["organization_id"], name: "index_inboxes_on_organization_id"
  end

  create_table "member_worklogs", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "membership_id", null: false
    t.date "date"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_id"], name: "index_member_worklogs_on_membership_id"
    t.index ["organization_id"], name: "index_member_worklogs_on_organization_id"
  end

  create_table "membership_worklogs", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "membership_id", null: false
    t.date "date"
    t.time "check_in"
    t.time "check_out"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.index ["membership_id"], name: "index_membership_worklogs_on_membership_id"
    t.index ["organization_id"], name: "index_membership_worklogs_on_organization_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "owner_id", null: false
    t.string "address"
    t.string "email"
    t.string "registration_number"
    t.string "tax_number"
    t.string "iban"
    t.integer "projects_count", default: 0, null: false
    t.integer "memberships_count", default: 0, null: false
    t.integer "tasks_count", default: 0, null: false
    t.index ["email"], name: "index_organizations_on_email"
    t.index ["name"], name: "index_organizations_on_name"
    t.index ["owner_id"], name: "index_organizations_on_owner_id"
    t.index ["registration_number"], name: "index_organizations_on_registration_number"
    t.index ["tax_number"], name: "index_organizations_on_tax_number"
  end

  create_table "project_members", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "user_id", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "user_id"], name: "index_project_members_on_project_id_and_user_id", unique: true
    t.index ["project_id"], name: "index_project_members_on_project_id"
    t.index ["user_id"], name: "index_project_members_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_manager_id", null: false
    t.string "color"
    t.boolean "archived"
    t.integer "tasks_count", default: 0, null: false
    t.index ["organization_id"], name: "index_projects_on_organization_id"
    t.index ["project_manager_id"], name: "index_projects_on_project_manager_id"
  end

  create_table "task_categories", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "color"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_task_categories_on_active"
    t.index ["organization_id", "name"], name: "index_task_categories_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_task_categories_on_organization_id"
  end

  create_table "task_timetrackings", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "membership_id", null: false
    t.date "date"
    t.time "start"
    t.time "end"
    t.integer "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_id"], name: "index_task_timetrackings_on_membership_id"
    t.index ["task_id"], name: "index_task_timetrackings_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "project_id", null: false
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "priority", default: "low"
    t.date "planned_start_date"
    t.date "planned_end_date"
    t.bigint "assignee_id", null: false
    t.bigint "reporter_id", null: false
    t.string "status", default: "open", null: false
    t.integer "comments_count", default: 0, null: false
    t.integer "task_timetrackings_count", default: 0, null: false
    t.bigint "task_category_id"
    t.index ["assignee_id", "status"], name: "index_tasks_on_assignee_id_and_status"
    t.index ["assignee_id"], name: "index_tasks_on_assignee_id"
    t.index ["organization_id", "priority"], name: "index_tasks_on_organization_id_and_priority"
    t.index ["organization_id", "status"], name: "index_tasks_on_organization_id_and_status"
    t.index ["organization_id", "task_category_id"], name: "index_tasks_on_organization_id_and_task_category_id"
    t.index ["organization_id"], name: "index_tasks_on_organization_id"
    t.index ["planned_end_date"], name: "index_tasks_on_planned_end_date"
    t.index ["planned_start_date"], name: "index_tasks_on_planned_start_date"
    t.index ["priority"], name: "index_tasks_on_priority"
    t.index ["project_id", "status"], name: "index_tasks_on_project_id_and_status"
    t.index ["project_id"], name: "index_tasks_on_project_id"
    t.index ["reporter_id"], name: "index_tasks_on_reporter_id"
    t.index ["status"], name: "index_tasks_on_status"
    t.index ["task_category_id"], name: "index_tasks_on_task_category_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "first_name"
    t.string "last_name"
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "memberships"
  add_foreign_key "comments", "tasks"
  add_foreign_key "inboxes", "organizations"
  add_foreign_key "member_worklogs", "memberships"
  add_foreign_key "member_worklogs", "organizations"
  add_foreign_key "membership_worklogs", "memberships"
  add_foreign_key "membership_worklogs", "organizations"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "organizations", "users", column: "owner_id"
  add_foreign_key "project_members", "projects"
  add_foreign_key "project_members", "users"
  add_foreign_key "projects", "memberships", column: "project_manager_id"
  add_foreign_key "projects", "organizations"
  add_foreign_key "task_categories", "organizations"
  add_foreign_key "task_timetrackings", "memberships"
  add_foreign_key "task_timetrackings", "tasks"
  add_foreign_key "tasks", "memberships", column: "assignee_id"
  add_foreign_key "tasks", "memberships", column: "reporter_id"
  add_foreign_key "tasks", "organizations"
  add_foreign_key "tasks", "projects"
  add_foreign_key "tasks", "task_categories"
end
