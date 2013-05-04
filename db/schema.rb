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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130503040414) do

  create_table "admins", :force => true do |t|
    t.string   "fullname"
    t.integer  "calnetID"
    t.string   "email"
    t.datetime "last_request_time"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "announcements", :force => true do |t|
    t.integer  "admin_id"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.boolean  "shown_on_homepage"
  end

  add_index "announcements", ["admin_id"], :name => "index_announcements_on_admin_id"

  create_table "complaints", :force => true do |t|
    t.string   "title"
    t.string   "ip_address"
    t.string   "user_email"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "status"
    t.integer  "admin_id"
  end

  create_table "faqs", :force => true do |t|
    t.integer  "admin_id"
    t.text     "question"
    t.text     "answer"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "faqs", ["admin_id"], :name => "index_faqs_on_admin_id"

  create_table "messages", :force => true do |t|
    t.integer  "complaint_id"
    t.integer  "user_id"
    t.integer  "admin_id"
    t.integer  "depth"
    t.text     "content"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "messages", ["admin_id"], :name => "index_messages_on_admin_id"
  add_index "messages", ["complaint_id"], :name => "index_messages_on_complaint_id"
  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"

  create_table "nodes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "ancestry"
    t.string   "description"
  end

  create_table "queries", :force => true do |t|
    t.integer  "admin_id"
    t.text     "description"
    t.text     "query_string"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "queries", ["admin_id"], :name => "index_queries_on_admin_id"

  create_table "requests", :force => true do |t|
    t.string   "ip_address"
    t.datetime "request_time"
    t.boolean  "isRegistered"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "resources", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "count"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "node_id"
    t.text     "content"
    t.text     "description"
  end

  create_table "users", :force => true do |t|
    t.integer  "calnetID"
    t.string   "email"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "fullname"
    t.datetime "last_request_time"
  end

end
