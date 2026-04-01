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

ActiveRecord::Schema[8.0].define(version: 2026_04_01_133345) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "careers", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["career_id"], name: "index_courses_on_career_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "course_id", null: false
    t.bigint "turma_id", null: false
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
    t.string "youtube_id", null: false
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
    t.index ["professor_id"], name: "index_materials_on_professor_id"
    t.index ["subject_id"], name: "index_materials_on_subject_id"
    t.index ["turma_id"], name: "index_materials_on_turma_id"
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
    t.text "address"
    t.boolean "internal", default: true, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["course_id"], name: "index_turmas_on_course_id"
    t.index ["professor_id"], name: "index_turmas_on_professor_id"
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
    t.index ["cpf"], name: "index_users_on_cpf", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "contracts", "courses"
  add_foreign_key "contracts", "enrollments"
  add_foreign_key "contracts", "students"
  add_foreign_key "courses", "careers"
  add_foreign_key "enrollments", "careers"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "students"
  add_foreign_key "enrollments", "turmas"
  add_foreign_key "events", "courses"
  add_foreign_key "lesson_completions", "lessons"
  add_foreign_key "lesson_completions", "students"
  add_foreign_key "lesson_pdfs", "lessons"
  add_foreign_key "lessons", "topics"
  add_foreign_key "materials", "subjects"
  add_foreign_key "materials", "turmas"
  add_foreign_key "materials", "users", column: "professor_id"
  add_foreign_key "questions", "lessons"
  add_foreign_key "questions", "students"
  add_foreign_key "questions", "subjects"
  add_foreign_key "questions", "users", column: "professor_id"
  add_foreign_key "students", "users"
  add_foreign_key "subjects", "courses"
  add_foreign_key "subjects", "users", column: "professor_id"
  add_foreign_key "topics", "subjects"
  add_foreign_key "turmas", "courses"
  add_foreign_key "turmas", "users", column: "professor_id"
end
