# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160615075819) do

  create_table "posts", force: :cascade do |t|
    t.string   "title",              limit: 255,  null: false
    t.text     "content",            limit: 2048, null: false
    t.integer  "author_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "posts", ["author_id"], name: "index_posts_on_author_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",              limit: 255,              null: false
    t.string   "name",               limit: 255,              null: false
    t.integer  "role",                           default: 1,  null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "encrypted_password",             default: "", null: false
  end

  add_index "users", ["email"], name: "index_users_on_email"

end
