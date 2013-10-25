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

ActiveRecord::Schema.define(:version => 20110921074035) do

  create_table "calls", :force => true do |t|
    t.string   "state"
    t.string   "conference_name"
    t.text     "conference_history"
    t.string   "account_sid"
    t.string   "to_zip"
    t.string   "from_state"
    t.string   "called"
    t.string   "from_country"
    t.string   "caller_country"
    t.string   "called_zip"
    t.string   "direction"
    t.string   "from_city"
    t.string   "called_country"
    t.string   "caller_state"
    t.string   "call_sid"
    t.string   "called_state"
    t.string   "from"
    t.string   "caller_zip"
    t.string   "from_zip"
    t.string   "application_sid"
    t.string   "call_status"
    t.string   "to_city"
    t.string   "to_state"
    t.string   "to"
    t.string   "to_country"
    t.string   "caller_city"
    t.string   "api_version"
    t.string   "caller"
    t.string   "called_city"
    t.datetime "waiting_at"
    t.datetime "ended_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

end
