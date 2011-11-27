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

ActiveRecord::Schema.define(:version => 20111127015711) do

  create_table "payments", :force => true do |t|
    t.string   "scenario"
    t.string   "paykey"
    t.integer  "amount"
    t.string   "status"
    t.string   "sender_email"
    t.datetime "timestamp"
    t.string   "tracking_id"
    t.text     "details"
    t.string   "currency"
  end

  create_table "preapprovals", :force => true do |t|
    t.string   "scenario"
    t.datetime "timestamp"
    t.string   "preapproval_key"
    t.integer  "max_num_payments"
    t.integer  "max_total_payments"
    t.integer  "max_per_payment"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "payment_period"
    t.integer  "max_payments_per_period"
    t.text     "details"
    t.string   "currency"
    t.string   "status"
  end

end
