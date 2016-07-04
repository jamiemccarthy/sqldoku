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

ActiveRecord::Schema.define(version: 20160704140408) do

  create_table "cells", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "symbol"
    t.integer "col"
    t.integer "row"
    t.integer "blk"
    t.boolean "possible",  default: true, null: false
    t.boolean "confirmed"
    t.integer "source"
    t.integer "puzzle_id"
    t.index ["puzzle_id", "blk", "symbol", "confirmed"], name: "index_cells_on_puzzle_id_and_blk_and_symbol_and_confirmed", unique: true, using: :btree
    t.index ["puzzle_id", "col", "row", "confirmed"], name: "index_cells_on_puzzle_id_and_col_and_row_and_confirmed", unique: true, using: :btree
    t.index ["puzzle_id", "col", "symbol", "confirmed"], name: "index_cells_on_puzzle_id_and_col_and_symbol_and_confirmed", unique: true, using: :btree
    t.index ["puzzle_id", "confirmed"], name: "index_cells_on_puzzle_id_and_confirmed", using: :btree
    t.index ["puzzle_id", "possible", "confirmed", "col", "row"], name: "index_cells_on_puzzle_id_possible_confirmed_col_row", using: :btree
    t.index ["puzzle_id", "possible", "symbol", "confirmed"], name: "index_cells_on_puzzle_id_possible_symbol_confirmed", using: :btree
    t.index ["puzzle_id", "row", "col", "symbol"], name: "index_cells_on_puzzle_id_and_row_and_col_and_symbol", unique: true, using: :btree
    t.index ["puzzle_id", "row", "symbol", "confirmed"], name: "index_cells_on_puzzle_id_and_row_and_symbol_and_confirmed", unique: true, using: :btree
    t.index ["puzzle_id"], name: "index_cells_on_puzzle_id", using: :btree
  end

  create_table "puzzles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "uuid",                        null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "solved",      default: false, null: false
    t.integer  "root",        default: 3,     null: false
    t.boolean  "cells_built", default: false
    t.index ["uuid"], name: "index_puzzles_on_uuid", unique: true, using: :btree
  end

  add_foreign_key "cells", "puzzles"
end
