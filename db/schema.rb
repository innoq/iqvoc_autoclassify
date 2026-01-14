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

ActiveRecord::Schema[8.1].define(version: 2025_03_26_182601) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "classification_traces", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "document_id"
    t.text "trace"
    t.datetime "updated_at", precision: nil
    t.index ["document_id"], name: "index_classification_traces_on_document_id"
  end

  create_table "classifications", id: :serial, force: :cascade do |t|
    t.string "concept_origin", limit: 4000
    t.datetime "created_at", precision: nil
    t.integer "document_id"
    t.text "findings"
    t.string "title"
    t.datetime "updated_at", precision: nil
    t.decimal "weighting", precision: 10, scale: 4
    t.index ["concept_origin"], name: "ix_classifications_on_origin"
    t.index ["document_id"], name: "index_classifications_on_document_id"
  end

  create_table "collection_members", id: :serial, force: :cascade do |t|
    t.integer "collection_id"
    t.integer "target_id"
    t.string "type"
    t.index ["collection_id", "target_id", "type"], name: "ix_collections_fk_type"
    t.index ["type"], name: "index_collection_members_on_type"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", precision: nil
    t.integer "document_id"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["document_id"], name: "index_comments_on_document_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "compound_form_contents", id: :serial, force: :cascade do |t|
    t.integer "compound_form_id"
    t.datetime "created_at", precision: nil
    t.integer "label_id"
    t.integer "order"
    t.datetime "updated_at", precision: nil
    t.index ["compound_form_id"], name: "ix_cfc_compound_form_id"
    t.index ["label_id"], name: "ix_cfc_label_id"
  end

  create_table "compound_forms", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "domain_id"
    t.datetime "updated_at", precision: nil
    t.index ["domain_id"], name: "ix_cf_fk"
  end

  create_table "concept_relations", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "owner_id"
    t.integer "rank", default: 100
    t.integer "target_id"
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.index ["owner_id", "target_id"], name: "ix_concept_relations_fk"
  end

  create_table "concepts", id: :serial, force: :cascade do |t|
    t.boolean "auto_classify", default: true, null: false
    t.datetime "created_at", precision: nil
    t.date "expired_at"
    t.date "follow_up"
    t.string "origin", limit: 4000
    t.date "published_at"
    t.integer "published_version_id"
    t.date "rdf_updated_at"
    t.integer "rev", default: 1
    t.boolean "to_review"
    t.boolean "top_term", default: false
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.index ["origin"], name: "ix_concepts_on_origin"
    t.index ["published_version_id"], name: "ix_concepts_publ_version_id"
  end

  create_table "configuration_settings", id: :serial, force: :cascade do |t|
    t.string "key"
    t.string "value"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.string "delayed_global_reference_id"
    t.integer "delayed_reference_id"
    t.string "delayed_reference_type"
    t.string "error_message"
    t.datetime "failed_at", precision: nil
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "locked_at", precision: nil
    t.string "locked_by"
    t.integer "priority", default: 0, null: false
    t.string "queue"
    t.datetime "run_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["delayed_global_reference_id"], name: "delayed_jobs_delayed_global_reference_id"
    t.index ["delayed_reference_id"], name: "delayed_jobs_delayed_reference_id"
    t.index ["delayed_reference_type"], name: "delayed_jobs_delayed_reference_type"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
    t.index ["queue"], name: "delayed_jobs_queue"
  end

  create_table "documents", id: :serial, force: :cascade do |t|
    t.text "content"
    t.string "content_hash"
    t.datetime "created_at", precision: nil
    t.jsonb "options"
    t.string "title"
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.string "uri"
    t.string "workflow_state"
  end

  create_table "exports", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "default_namespace"
    t.integer "file_type"
    t.datetime "finished_at", precision: nil
    t.text "output"
    t.boolean "success", default: false
    t.string "token"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["user_id"], name: "index_exports_on_user_id"
  end

  create_table "imports", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "default_namespace"
    t.datetime "finished_at", precision: nil
    t.string "import_file"
    t.text "output"
    t.boolean "publish"
    t.boolean "success", default: false
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["user_id"], name: "index_imports_on_user_id"
  end

  create_table "inflectionals", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "label_id"
    t.string "normal_hash"
    t.datetime "updated_at", precision: nil
    t.string "value", limit: 4000
    t.index ["label_id"], name: "ix_inflectionals_fk"
    t.index ["normal_hash"], name: "ix_inflectionals_normal_hash"
    t.index ["value"], name: "index_inflectionals_on_value"
  end

  create_table "label_relations", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "domain_id"
    t.integer "range_id"
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.index ["domain_id", "range_id", "type"], name: "ix_label_rel_dom_rng_type"
    t.index ["type"], name: "ix_label_relations_on_type"
  end

  create_table "labelings", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "owner_id"
    t.integer "target_id"
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.index ["owner_id", "target_id", "type"], name: "ix_labelings_fk_type"
    t.index ["type"], name: "ix_labelings_on_type"
  end

  create_table "labels", id: :serial, force: :cascade do |t|
    t.boolean "auto_classify", default: true, null: false
    t.string "base_form"
    t.datetime "created_at", precision: nil
    t.date "expired_at"
    t.date "follow_up"
    t.string "inflectional_code"
    t.string "language"
    t.string "origin", limit: 4000
    t.date "published_at"
    t.integer "published_version_id"
    t.date "rdf_updated_at"
    t.integer "rev", default: 1
    t.boolean "to_review"
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.string "value", limit: 1024
    t.index ["language"], name: "ix_labels_on_language"
    t.index ["origin"], name: "ix_labels_on_origin"
    t.index ["published_version_id"], name: "ix_labels_on_published_v"
  end

  create_table "matches", id: :serial, force: :cascade do |t|
    t.integer "concept_id"
    t.datetime "created_at", precision: nil
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.string "value"
    t.index ["concept_id", "type"], name: "ix_matches_fk_type"
    t.index ["type"], name: "ix_matches_on_type"
  end

  create_table "notations", id: :serial, force: :cascade do |t|
    t.integer "concept_id"
    t.string "data_type", limit: 4000
    t.string "value", limit: 4000
    t.index ["concept_id"], name: "index_notations_on_concept_id"
  end

  create_table "note_annotations", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "language"
    t.string "namespace", limit: 50
    t.integer "note_id"
    t.string "predicate", limit: 50
    t.datetime "updated_at", precision: nil
    t.string "value", limit: 1024
    t.index ["note_id"], name: "ix_note_annotations_fk"
    t.index ["value"], name: "index_note_annotations_on_value"
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "language", limit: 2
    t.integer "owner_id"
    t.string "owner_type", null: false
    t.integer "position"
    t.string "type", limit: 50
    t.datetime "updated_at", precision: nil
    t.string "value", limit: 4000
    t.index ["language"], name: "ix_notes_on_language"
    t.index ["owner_id", "owner_type", "type"], name: "ix_notes_fk_type"
    t.index ["type"], name: "ix_notes_on_type"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.boolean "active"
    t.text "comment"
    t.datetime "created_at", precision: nil
    t.string "crypted_password"
    t.datetime "current_login_at", precision: nil
    t.string "current_login_ip"
    t.string "email"
    t.integer "failed_login_count", default: 0, null: false
    t.string "forename"
    t.datetime "last_login_at", precision: nil
    t.string "last_login_ip"
    t.datetime "last_request_at", precision: nil
    t.integer "login_count", default: 0, null: false
    t.string "password_salt"
    t.string "perishable_token"
    t.string "persistence_token"
    t.string "role"
    t.string "surname"
    t.string "telephone_number"
    t.string "type", default: "User"
    t.datetime "updated_at", precision: nil
  end

  add_foreign_key "classification_traces", "documents", on_update: :cascade, on_delete: :cascade
  add_foreign_key "classifications", "documents", on_update: :cascade, on_delete: :cascade
  add_foreign_key "collection_members", "concepts", column: "collection_id", on_update: :cascade
  add_foreign_key "collection_members", "concepts", column: "target_id", on_update: :cascade
  add_foreign_key "compound_form_contents", "compound_forms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "compound_form_contents", "labels", on_update: :cascade, on_delete: :cascade
  add_foreign_key "compound_forms", "labels", column: "domain_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "concept_relations", "concepts", column: "owner_id", on_update: :cascade
  add_foreign_key "concept_relations", "concepts", column: "target_id", on_update: :cascade
  add_foreign_key "exports", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "imports", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "inflectionals", "labels", on_update: :cascade, on_delete: :cascade
  add_foreign_key "label_relations", "labels", column: "domain_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "label_relations", "labels", column: "range_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "labelings", "concepts", column: "owner_id", on_update: :cascade
  add_foreign_key "labelings", "labels", column: "target_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "matches", "concepts", on_update: :cascade, on_delete: :cascade
  add_foreign_key "notations", "concepts", on_update: :cascade
  add_foreign_key "note_annotations", "notes", on_update: :cascade, on_delete: :cascade
end
