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

ActiveRecord::Schema.define(:version => 20120811024202) do

  create_table "boards", :force => true do |t|
    t.integer "game_id"
    t.integer "height"
    t.integer "width"
    t.integer "robber_col"
    t.integer "robber_row"
  end

  create_table "cards", :force => true do |t|
    t.integer  "game_id"
    t.integer  "player_id"
    t.string   "type"
    t.string   "state"
    t.integer  "bricks"
    t.integer  "grain"
    t.integer  "lumber"
    t.integer  "ore"
    t.integer  "wool"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "resource_type"
  end

  create_table "dice_rolls", :force => true do |t|
    t.integer  "game_id"
    t.integer  "value"
    t.integer  "turn"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "player_id"
  end

  create_table "discards", :force => true do |t|
    t.integer  "lumber"
    t.integer  "grain"
    t.integer  "bricks"
    t.integer  "wool"
    t.integer  "ore"
    t.integer  "player_id"
    t.integer  "game_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "edges", :force => true do |t|
    t.integer "row"
    t.integer "col"
    t.integer "player_id"
    t.integer "board_id"
  end

  create_table "exchanges", :force => true do |t|
    t.integer  "player_id"
    t.integer  "game_id"
    t.integer  "bricks"
    t.integer  "grain"
    t.integer  "ore"
    t.integer  "wool"
    t.integer  "lumber"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "games", :force => true do |t|
    t.string   "state"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "current_turn"
    t.string   "phase"
    t.integer  "current_discard_resource_limit"
    t.integer  "army_cards"
    t.integer  "monopoly_cards"
    t.integer  "year_of_plenty_cards"
    t.integer  "road_building_cards"
    t.integer  "victory_point_cards"
    t.integer  "largest_army_size"
    t.integer  "largest_army_player_id"
    t.integer  "longest_road_length"
    t.integer  "longest_road_player_id"
    t.integer  "cards_count"
    t.integer  "card_id"
    t.integer  "current_discard_player_id"
    t.integer  "current_player_id"
  end

  create_table "hexes", :force => true do |t|
    t.integer "row"
    t.integer "col"
    t.string  "hex_type"
    t.integer "roll"
    t.integer "board_id"
    t.integer "harbor_position"
    t.string  "harbor_type"
  end

  create_table "nodes", :force => true do |t|
    t.integer "row"
    t.integer "col"
    t.integer "player_id"
    t.integer "board_id"
    t.string  "state"
  end

  create_table "offer_responses", :force => true do |t|
    t.integer  "player_id"
    t.integer  "offer_id"
    t.boolean  "agreed"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "offers", :force => true do |t|
    t.integer  "bricks"
    t.integer  "grain"
    t.integer  "ore"
    t.integer  "wool"
    t.integer  "lumber"
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.integer  "game_id"
    t.string   "state"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "players", :force => true do |t|
    t.integer "bricks"
    t.integer "grain"
    t.integer "ore"
    t.integer "wool"
    t.integer "lumber"
    t.integer "settlements"
    t.integer "cities"
    t.integer "roads"
    t.integer "number"
    t.integer "user_id"
    t.integer "game_id"
    t.integer "points"
    t.string  "state"
    t.integer "resources"
    t.integer "visible_points"
    t.integer "hidden_points"
    t.integer "bricks_exchange_rate"
    t.integer "grain_exchange_rate"
    t.integer "lumber_exchange_rate"
    t.integer "ore_exchange_rate"
    t.integer "wool_exchange_rate"
    t.integer "army_size"
  end

  create_table "robberies", :force => true do |t|
    t.integer  "row"
    t.integer  "col"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "bricks"
    t.integer  "grain"
    t.integer  "lumber"
    t.integer  "ore"
    t.integer  "wool"
    t.integer  "game_id"
    t.integer  "sender_id"
    t.integer  "recipient_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
