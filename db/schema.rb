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

ActiveRecord::Schema[8.0].define(version: 2026_04_15_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "access_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.string "device"
    t.string "browser"
    t.string "action", default: "login", null: false
    t.boolean "success", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_access_logs_on_created_at"
    t.index ["user_id"], name: "index_access_logs_on_user_id"
  end

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

  create_table "announcements", force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.integer "category", default: 0, null: false
    t.integer "audience", default: 0, null: false
    t.boolean "pinned", default: false, null: false
    t.boolean "active", default: true, null: false
    t.datetime "expires_at"
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_announcements_on_active"
    t.index ["audience"], name: "index_announcements_on_audience"
    t.index ["author_id"], name: "index_announcements_on_author_id"
    t.index ["category"], name: "index_announcements_on_category"
    t.index ["pinned"], name: "index_announcements_on_pinned"
  end

  create_table "careers", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cities", force: :cascade do |t|
    t.string "name", null: false
    t.string "state", limit: 2, null: false
    t.string "ibge_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ibge_code"], name: "index_cities_on_ibge_code", unique: true, where: "(ibge_code IS NOT NULL)"
    t.index ["name", "state"], name: "index_cities_on_name_and_state", unique: true
  end

  create_table "contracts", force: :cascade do |t|
    t.bigint "enrollment_id", null: false
    t.bigint "student_id", null: false
    t.bigint "course_id", null: false
    t.text "contract_text"
    t.string "version", default: "1.0", null: false
    t.datetime "signed_at"
    t.integer "status", default: 0, null: false
    t.string "pdf_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_contracts_on_course_id"
    t.index ["enrollment_id"], name: "index_contracts_on_enrollment_id"
    t.index ["student_id"], name: "index_contracts_on_student_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "price_cents", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "access_type", default: 0, null: false
    t.integer "duration_in_days"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "career_id"
    t.string "online_url"
    t.index ["career_id"], name: "index_courses_on_career_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "course_id", null: false
    t.bigint "turma_id"
    t.bigint "career_id"
    t.integer "status", default: 0, null: false
    t.date "started_at", null: false
    t.date "expires_at"
    t.integer "enrollment_type", default: 0, null: false
    t.string "payment_method"
    t.integer "total_paid_cents", default: 0, null: false
    t.boolean "contract_signed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["career_id"], name: "index_enrollments_on_career_id"
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["student_id"], name: "index_enrollments_on_student_id"
    t.index ["turma_id"], name: "index_enrollments_on_turma_id"
  end

  create_table "event_lotes", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "quantity", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_lotes_on_event_id"
  end

  create_table "event_materials", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "subject_id", null: false
    t.bigint "professor_id", null: false
    t.string "title", null: false
    t.string "file_size"
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_materials_on_event_id"
    t.index ["professor_id"], name: "index_event_materials_on_professor_id"
    t.index ["subject_id"], name: "index_event_materials_on_subject_id"
  end

  create_table "event_registrations", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "student_id", null: false
    t.string "ticket_token"
    t.boolean "attended"
    t.datetime "attended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "event_lote_id"
    t.index ["event_id"], name: "index_event_registrations_on_event_id"
    t.index ["event_lote_id"], name: "index_event_registrations_on_event_lote_id"
    t.index ["student_id"], name: "index_event_registrations_on_student_id"
    t.index ["ticket_token"], name: "index_event_registrations_on_ticket_token", unique: true
  end

  create_table "event_subjects", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "subject_id"], name: "index_event_subjects_on_event_id_and_subject_id", unique: true
    t.index ["event_id"], name: "index_event_subjects_on_event_id"
    t.index ["subject_id"], name: "index_event_subjects_on_subject_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "course_id"
    t.string "title", null: false
    t.text "description"
    t.integer "event_type", default: 0, null: false
    t.date "date", null: false
    t.string "start_time", null: false
    t.string "end_time", null: false
    t.string "location"
    t.integer "max_participants", default: 100, null: false
    t.integer "registered_count", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0"
    t.boolean "is_free", default: true, null: false
    t.index ["course_id"], name: "index_events_on_course_id"
  end

  create_table "lesson_completions", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "lesson_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_lesson_completions_on_lesson_id"
    t.index ["student_id", "lesson_id"], name: "index_lesson_completions_on_student_id_and_lesson_id", unique: true
    t.index ["student_id"], name: "index_lesson_completions_on_student_id"
  end

  create_table "lesson_pdfs", force: :cascade do |t|
    t.bigint "lesson_id", null: false
    t.string "name", null: false
    t.string "file_size"
    t.string "file_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_lesson_pdfs_on_lesson_id"
  end

  create_table "lessons", force: :cascade do |t|
    t.bigint "topic_id", null: false
    t.string "title", null: false
    t.string "duration"
    t.string "youtube_id"
    t.integer "position", default: 0, null: false
    t.boolean "available", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_lessons_on_topic_id"
  end

  create_table "materials", force: :cascade do |t|
    t.bigint "professor_id", null: false
    t.bigint "subject_id"
    t.bigint "turma_id"
    t.string "title", null: false
    t.integer "material_type", default: 0, null: false
    t.string "file_name"
    t.string "file_url"
    t.string "file_size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.index ["professor_id"], name: "index_materials_on_professor_id"
    t.index ["subject_id"], name: "index_materials_on_subject_id"
    t.index ["turma_id"], name: "index_materials_on_turma_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "notifiable_type", null: false
    t.integer "notifiable_id", null: false
    t.string "title", null: false
    t.string "body"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "professor_id", null: false
    t.bigint "lesson_id", null: false
    t.bigint "subject_id", null: false
    t.text "text", null: false
    t.string "video_moment"
    t.integer "status", default: 0, null: false
    t.text "answer"
    t.datetime "answered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_questions_on_lesson_id"
    t.index ["professor_id"], name: "index_questions_on_professor_id"
    t.index ["student_id"], name: "index_questions_on_student_id"
    t.index ["subject_id"], name: "index_questions_on_subject_id"
  end

  create_table "students", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", null: false
    t.string "email", null: false
    t.string "whatsapp"
    t.string "cpf", null: false
    t.text "street"
    t.boolean "internal", default: true, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "instagram"
    t.integer "situacao", default: 0, null: false
    t.string "address_number"
    t.string "address_complement"
    t.string "neighborhood"
    t.string "cep"
    t.bigint "city_id"
    t.index ["city_id"], name: "index_students_on_city_id"
    t.index ["cpf"], name: "index_students_on_cpf", unique: true
    t.index ["email"], name: "index_students_on_email", unique: true
    t.index ["user_id"], name: "index_students_on_user_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.bigint "course_id"
    t.bigint "professor_id"
    t.string "name", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_subjects_on_course_id"
    t.index ["professor_id"], name: "index_subjects_on_professor_id"
  end

  create_table "topics", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.string "title", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_topics_on_subject_id"
  end

  create_table "turma_class_days", force: :cascade do |t|
    t.bigint "turma_id", null: false
    t.bigint "subject_id", null: false
    t.date "date", null: false
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "professor_id"
    t.time "start_time"
    t.time "end_time"
    t.index ["professor_id"], name: "index_turma_class_days_on_professor_id"
    t.index ["subject_id"], name: "index_turma_class_days_on_subject_id"
    t.index ["turma_id", "date"], name: "index_turma_class_days_on_turma_id_and_date"
    t.index ["turma_id"], name: "index_turma_class_days_on_turma_id"
  end

  create_table "turmas", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "professor_id"
    t.string "name", null: false
    t.string "shift"
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.string "schedule"
    t.integer "max_students", default: 40, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "modalidade", default: "presencial", null: false
    t.index ["course_id"], name: "index_turmas_on_course_id"
    t.index ["professor_id"], name: "index_turmas_on_professor_id"
  end

  create_table "user_types", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "description"
    t.boolean "active", default: true, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_user_types_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "cpf", null: false
    t.integer "role", default: 0, null: false
    t.decimal "commission_percent", precision: 5, scale: 2
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_type_id"
    t.string "setup_password_token"
    t.datetime "setup_password_token_expires_at"
    t.string "session_token"
    t.index ["cpf"], name: "index_users_on_cpf", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["session_token"], name: "index_users_on_session_token"
    t.index ["setup_password_token"], name: "index_users_on_setup_password_token", unique: true, where: "(setup_password_token IS NOT NULL)"
    t.index ["user_type_id"], name: "index_users_on_user_type_id"
  end

  add_foreign_key "access_logs", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "announcements", "users", column: "author_id"
  add_foreign_key "contracts", "courses"
  add_foreign_key "contracts", "enrollments"
  add_foreign_key "contracts", "students"
  add_foreign_key "courses", "careers"
  add_foreign_key "enrollments", "careers"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "students"
  add_foreign_key "enrollments", "turmas"
  add_foreign_key "event_lotes", "events"
  add_foreign_key "event_materials", "events"
  add_foreign_key "event_materials", "subjects"
  add_foreign_key "event_materials", "users", column: "professor_id"
  add_foreign_key "event_registrations", "event_lotes"
  add_foreign_key "event_registrations", "events"
  add_foreign_key "event_registrations", "students"
  add_foreign_key "event_subjects", "events"
  add_foreign_key "event_subjects", "subjects"
  add_foreign_key "events", "courses"
  add_foreign_key "lesson_completions", "lessons"
  add_foreign_key "lesson_completions", "students"
  add_foreign_key "lesson_pdfs", "lessons"
  add_foreign_key "lessons", "topics"
  add_foreign_key "materials", "subjects"
  add_foreign_key "materials", "turmas"
  add_foreign_key "materials", "users", column: "professor_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "questions", "lessons"
  add_foreign_key "questions", "students"
  add_foreign_key "questions", "subjects"
  add_foreign_key "questions", "users", column: "professor_id"
  add_foreign_key "students", "cities"
  add_foreign_key "students", "users"
  add_foreign_key "subjects", "courses"
  add_foreign_key "subjects", "users", column: "professor_id"
  add_foreign_key "topics", "subjects"
  add_foreign_key "turma_class_days", "subjects"
  add_foreign_key "turma_class_days", "turmas"
  add_foreign_key "turma_class_days", "users", column: "professor_id"
  add_foreign_key "turmas", "courses"
  add_foreign_key "turmas", "users", column: "professor_id"
  add_foreign_key "users", "user_types"
end
