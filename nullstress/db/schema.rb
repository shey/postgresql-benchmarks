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

ActiveRecord::Schema[8.0].define(version: 2025_07_07_002831) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "pings", force: :cascade do |t|
    t.bigint "sensor_id", null: false
    t.integer "status_code"
    t.float "response_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_pings_on_created_at"
    t.index ["sensor_id", "created_at"], name: "index_pings_on_sensor_id_and_created_at"
    t.index ["sensor_id", "status_code"], name: "index_pings_on_sensor_id_and_status_code"
    t.index ["sensor_id"], name: "index_pings_on_sensor_id"
  end

  create_table "sensors", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.string "sensor_type"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "pings", "sensors"
end
