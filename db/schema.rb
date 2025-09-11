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

ActiveRecord::Schema[7.2].define(version: 2025_09_11_170539) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "awards", force: :cascade do |t|
    t.integer "year"
    t.string "name"
    t.bigint "player_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_awards_on_player_id"
  end

  create_table "batting_stats", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "game_id", null: false
    t.integer "plate_appearances"
    t.integer "at_bats", default: 0
    t.integer "hits", default: 0
    t.integer "home_runs", default: 0
    t.integer "rbi", default: 0
    t.integer "stolen_bases", default: 0
    t.integer "strikeouts", default: 0
    t.integer "walks_and_hbp"
    t.integer "sacrifices"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "batting_order"
    t.string "participation_type"
    t.integer "doubles", default: 0
    t.integer "triples", default: 0
    t.integer "runs", default: 0
    t.integer "walks", default: 0
    t.integer "sacrifice_bunts", default: 0
    t.integer "sacrifice_flies", default: 0
    t.integer "double_plays", default: 0
    t.integer "fielding_errors", default: 0
    t.string "fielding_position"
    t.index ["game_id"], name: "index_batting_stats_on_game_id"
    t.index ["player_id"], name: "index_batting_stats_on_player_id"
  end

  create_table "best_order_players", force: :cascade do |t|
    t.bigint "best_order_id", null: false
    t.bigint "player_id", null: false
    t.integer "batting_order"
    t.string "fielding_position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["best_order_id"], name: "index_best_order_players_on_best_order_id"
    t.index ["player_id"], name: "index_best_order_players_on_player_id"
  end

  create_table "best_orders", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "games", force: :cascade do |t|
    t.date "game_date"
    t.string "day_night"
    t.string "home_away"
    t.integer "our_score"
    t.integer "opponent_score"
    t.bigint "opponent_id", null: false
    t.bigint "stadium_id"
    t.bigint "winning_pitcher_id"
    t.bigint "losing_pitcher_id"
    t.bigint "saving_pitcher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "result"
    t.integer "our_hits"
    t.integer "opponent_hits"
    t.integer "our_errors"
    t.integer "opponent_errors"
    t.string "first_move"
    t.string "our_score_details", default: [], array: true
    t.string "opponent_score_details", default: [], array: true
    t.boolean "is_favorite", default: false, null: false
    t.index ["losing_pitcher_id"], name: "index_games_on_losing_pitcher_id"
    t.index ["opponent_id"], name: "index_games_on_opponent_id"
    t.index ["saving_pitcher_id"], name: "index_games_on_saving_pitcher_id"
    t.index ["stadium_id"], name: "index_games_on_stadium_id"
    t.index ["winning_pitcher_id"], name: "index_games_on_winning_pitcher_id"
  end

  create_table "ocr_results", force: :cascade do |t|
    t.string "session_key"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_key"], name: "index_ocr_results_on_session_key"
  end

  create_table "opponents", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "stadium_id"
    t.string "short_name"
    t.index ["stadium_id"], name: "index_opponents_on_stadium_id"
  end

  create_table "our_teams", force: :cascade do |t|
    t.string "name"
    t.string "league"
    t.bigint "stadium_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_name"
    t.index ["stadium_id"], name: "index_our_teams_on_stadium_id"
  end

  create_table "pitching_stats", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "game_id", null: false
    t.string "pitcher_result"
    t.integer "hits_allowed"
    t.integer "strikeouts"
    t.integer "walks_and_hbp"
    t.integer "earned_runs"
    t.integer "hit_by_pitches"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pitching_order"
    t.integer "batters_faced", default: 0, null: false
    t.integer "pitches_thrown", default: 0, null: false
    t.integer "walks", default: 0, null: false
    t.integer "runs_allowed", default: 0, null: false
    t.integer "wild_pitches", default: 0, null: false
    t.integer "home_runs_allowed", default: 0, null: false
    t.integer "outs_pitched", default: 0, null: false
    t.integer "holds", default: 0, null: false
    t.integer "hold_points", default: 0, null: false
    t.integer "wins", default: 0, null: false
    t.integer "losses", default: 0, null: false
    t.integer "saves", default: 0, null: false
    t.index ["game_id"], name: "index_pitching_stats_on_game_id"
    t.index ["player_id"], name: "index_pitching_stats_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.string "jersey_number"
    t.string "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "throwing_hand"
    t.string "batting_hand"
    t.bigint "our_team_id"
    t.string "status", default: "active", null: false
    t.string "departure_reason"
    t.date "birthday"
    t.text "join_background"
    t.index ["our_team_id"], name: "index_players_on_our_team_id"
  end

  create_table "real_player_stats", force: :cascade do |t|
    t.integer "year"
    t.string "player_name"
    t.string "team_name"
    t.float "batting_average"
    t.integer "home_runs"
    t.integer "rbi"
    t.float "era"
    t.integer "wins"
    t.integer "strikeouts"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "appearances"
    t.integer "starts"
    t.integer "complete_games"
    t.integer "shutouts"
    t.integer "no_walks"
    t.integer "losses"
    t.integer "saves"
    t.integer "holds"
    t.float "winning_percentage"
    t.integer "batters_faced"
    t.float "innings_pitched"
    t.integer "hits_allowed"
    t.integer "home_runs_allowed"
    t.integer "walks"
    t.integer "wild_pitches"
    t.integer "runs_allowed"
    t.integer "earned_runs"
    t.float "whip"
    t.integer "games"
    t.integer "plate_appearances"
    t.integer "at_bats"
    t.integer "runs"
    t.integer "hits"
    t.integer "doubles"
    t.integer "triples"
    t.integer "stolen_bases"
    t.integer "sacrifice_bunts"
    t.integer "sacrifice_flies"
    t.integer "batter_walks"
    t.integer "batter_strikeouts"
    t.integer "double_plays"
    t.float "on_base_percentage"
    t.float "slugging_percentage"
    t.float "ops"
  end

  create_table "real_team_stats", force: :cascade do |t|
    t.integer "year"
    t.string "team_name"
    t.float "batting_average"
    t.integer "hits"
    t.integer "home_runs"
    t.integer "rbi"
    t.float "on_base_percentage"
    t.integer "stolen_bases"
    t.float "ops"
    t.float "era"
    t.integer "wins"
    t.integer "strikeouts"
    t.integer "holds"
    t.integer "saves"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "stadiums", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "yearly_stats", force: :cascade do |t|
    t.integer "year"
    t.integer "games"
    t.integer "at_bats"
    t.integer "plate_appearances"
    t.integer "hits"
    t.integer "doubles"
    t.integer "triples"
    t.integer "home_runs"
    t.integer "total_bases"
    t.integer "rbi"
    t.integer "runs"
    t.integer "stolen_bases"
    t.integer "walks"
    t.integer "strikeouts"
    t.integer "sacrifice_bunts"
    t.integer "sacrifice_flies"
    t.float "batting_average"
    t.float "on_base_percentage"
    t.float "slugging_percentage"
    t.float "ops"
    t.float "era"
    t.integer "appearances"
    t.integer "wins"
    t.integer "losses"
    t.integer "saves"
    t.integer "holds"
    t.float "innings_pitched"
    t.integer "hits_allowed"
    t.integer "home_runs_allowed"
    t.integer "strikeouts_pitched"
    t.integer "walks_allowed"
    t.integer "runs_allowed"
    t.integer "earned_runs"
    t.float "whip"
    t.integer "opponent_id"
    t.bigint "player_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stats_type", null: false
    t.integer "double_plays", default: 0, null: false
    t.integer "fielding_errors", default: 0, null: false
    t.integer "starts", default: 0, null: false
    t.integer "complete_games", default: 0, null: false
    t.integer "shutouts", default: 0, null: false
    t.integer "no_walk_complete_games", default: 0, null: false
    t.integer "outs_pitched", default: 0, null: false
    t.integer "wild_pitches", default: 0, null: false
    t.integer "qs", default: 0, null: false
    t.integer "hqs", default: 0, null: false
    t.float "k_per_nine", default: 0.0, null: false
    t.float "k_bb", default: 0.0, null: false
    t.float "fip", default: 0.0, null: false
    t.float "iso"
    t.float "isod"
    t.float "qs_rate"
    t.float "hqs_rate"
    t.index ["player_id", "year", "stats_type"], name: "index_yearly_stats_on_player_id_and_year_and_stats_type", unique: true
    t.index ["player_id"], name: "index_yearly_stats_on_player_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "awards", "players"
  add_foreign_key "batting_stats", "games"
  add_foreign_key "batting_stats", "players"
  add_foreign_key "best_order_players", "best_orders"
  add_foreign_key "best_order_players", "players"
  add_foreign_key "games", "opponents"
  add_foreign_key "games", "players", column: "losing_pitcher_id"
  add_foreign_key "games", "players", column: "saving_pitcher_id"
  add_foreign_key "games", "players", column: "winning_pitcher_id"
  add_foreign_key "games", "stadiums"
  add_foreign_key "opponents", "stadiums"
  add_foreign_key "our_teams", "stadiums"
  add_foreign_key "pitching_stats", "games"
  add_foreign_key "pitching_stats", "players"
  add_foreign_key "players", "our_teams"
  add_foreign_key "yearly_stats", "players"
end
