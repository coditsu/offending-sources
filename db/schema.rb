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

ActiveRecord::Schema.define(version: 0) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "dependencies", id: :serial, force: :cascade do |t|
    t.string "requirements", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "rubygem_id"
    t.integer "version_id"
    t.string "scope", limit: 255
    t.string "unresolved_name", limit: 255
    t.index ["rubygem_id"], name: "index_dependencies_on_rubygem_id"
    t.index ["unresolved_name"], name: "index_dependencies_on_unresolved_name"
    t.index ["version_id"], name: "index_dependencies_on_version_id"
  end

  create_table "gem_downloads", id: :serial, force: :cascade do |t|
    t.integer "rubygem_id", null: false
    t.integer "version_id", null: false
    t.bigint "count"
    t.index ["rubygem_id", "version_id"], name: "index_gem_downloads_on_rubygem_id_and_version_id", unique: true
    t.index ["version_id", "rubygem_id", "count"], name: "index_gem_downloads_on_version_id_and_rubygem_id_and_count"
  end

  create_table "linksets", id: :serial, force: :cascade do |t|
    t.integer "rubygem_id"
    t.string "home", limit: 255
    t.string "wiki", limit: 255
    t.string "docs", limit: 255
    t.string "mail", limit: 255
    t.string "code", limit: 255
    t.string "bugs", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["rubygem_id"], name: "index_linksets_on_rubygem_id"
  end

  create_table "rubygems", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug", limit: 255
    t.index "upper((name)::text) varchar_pattern_ops", name: "index_rubygems_upcase"
    t.index ["name"], name: "index_rubygems_on_name", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.text "authors"
    t.text "description"
    t.string "number", limit: 255
    t.integer "rubygem_id"
    t.datetime "built_at"
    t.datetime "updated_at"
    t.text "summary"
    t.string "platform", limit: 255
    t.datetime "created_at"
    t.boolean "indexed", default: true
    t.boolean "prerelease"
    t.integer "position"
    t.boolean "latest"
    t.string "full_name", limit: 255
    t.string "licenses", limit: 255
    t.integer "size"
    t.text "requirements"
    t.string "required_ruby_version", limit: 255
    t.string "sha256", limit: 255
    t.hstore "metadata", default: {}, null: false
    t.string "required_rubygems_version"
    t.datetime "yanked_at"
    t.string "info_checksum"
    t.string "yanked_info_checksum"
    t.index "lower((full_name)::text)", name: "index_versions_on_lower_full_name"
    t.index ["built_at"], name: "index_versions_on_built_at"
    t.index ["created_at"], name: "index_versions_on_created_at"
    t.index ["full_name"], name: "index_versions_on_full_name"
    t.index ["indexed"], name: "index_versions_on_indexed"
    t.index ["number"], name: "index_versions_on_number"
    t.index ["position"], name: "index_versions_on_position"
    t.index ["prerelease"], name: "index_versions_on_prerelease"
    t.index ["rubygem_id", "number", "platform"], name: "index_versions_on_rubygem_id_and_number_and_platform", unique: true
    t.index ["rubygem_id"], name: "index_versions_on_rubygem_id"
  end

end
