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

ActiveRecord::Schema.define(version: 20140528174411) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "apps", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.hstore   "env",            default: {}
    t.string   "git"
    t.hstore   "formation",      default: {"web"=>"1"}
    t.integer  "version",        default: 0
    t.integer  "logplex_id"
    t.hstore   "logplex_tokens", default: {}
    t.integer  "user_id"
  end

  create_table "drains", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.integer  "drain_id"
    t.string   "token"
    t.integer  "app_id"
  end

  create_table "gears", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "number"
    t.integer  "port"
    t.string   "ip"
    t.string   "container_id"
    t.time     "started_at"
    t.integer  "app_id"
    t.string   "proctype"
  end

  add_index "gears", ["number", "proctype"], name: "index_gears_on_number_and_proctype", unique: true, using: :btree

  create_table "keys", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "key"
    t.string   "fingerprint"
    t.integer  "user_id"
  end

  create_table "releases", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.integer  "version"
    t.integer  "app_id"
  end

  create_table "users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "email",                  default: ""
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.time     "reset_password_sent_at"
    t.time     "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.time     "current_sign_in_at"
    t.time     "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "api_key"
    t.integer  "user_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
