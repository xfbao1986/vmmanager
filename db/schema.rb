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

ActiveRecord::Schema.define(version: 20141007083406) do

  create_table "destroy_vm_requests", force: true do |t|
    t.string   "operator",                          null: false
    t.string   "vm_host",                           null: false
    t.string   "vm_user",                           null: false
    t.string   "state",         default: "created"
    t.datetime "completed_at"
    t.text     "result_detail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.string   "vm_ip"
  end

  create_table "dns_record_requests", force: true do |t|
    t.string   "operator",                          null: false
    t.string   "operation",                         null: false
    t.string   "hostname",                          null: false
    t.string   "state",         default: "waiting"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.text     "result_detail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hosts", force: true do |t|
    t.integer  "pool_id"
    t.string   "name",                                   null: false
    t.string   "ipaddress"
    t.integer  "num_of_vms"
    t.decimal  "storage_used",  precision: 10, scale: 2
    t.decimal  "storage_total", precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hosts", ["pool_id"], name: "index_hosts_on_pool_id", using: :btree

  create_table "pools", force: true do |t|
    t.string   "name"
    t.integer  "num_of_vms"
    t.decimal  "storage_used",  precision: 10, scale: 2
    t.decimal  "storage_total", precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "setups", force: true do |t|
    t.string   "host",                             null: false
    t.string   "user",                             null: false
    t.string   "ssh_key"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "setup_role"
    t.string   "state",        default: "created"
    t.boolean  "dry_run"
    t.datetime "completed_at"
  end

  create_table "shutdown_requests", force: true do |t|
    t.string   "operator"
    t.string   "state"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "vm_host"
    t.string   "vm_user"
    t.text     "result_details"
  end

  create_table "users", force: true do |t|
    t.string   "name",                                null: false
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "email",                  default: "", null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "vms", force: true do |t|
    t.string   "hostname",                          null: false
    t.string   "ipaddr"
    t.text     "login_info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "active_state",      default: 0
    t.string   "user"
    t.boolean  "deletable"
    t.boolean  "skipcheck",         default: false
    t.datetime "last_confirmed_at"
    t.datetime "last_shutdown_at"
    t.datetime "deleted_at"
  end

end
