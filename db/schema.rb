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

ActiveRecord::Schema.define(:version => 20120713164818) do

  create_table "cost_study_market_sector_percentile", :id => false, :force => true do |t|
    t.text   "market_sector",                 :null => false
    t.string "percentile",      :limit => 24, :null => false
    t.float  "legal_cost",                    :null => false
    t.float  "settlement_cost",               :null => false
    t.float  "total_cost",                    :null => false
  end

  create_table "crunch_acquisitions_fnl", :id => false, :force => true do |t|
    t.integer "acquisition_id",                          :null => false
    t.integer "crunch_ent_id",            :limit => 8
    t.string  "crunch_ent_name",          :limit => nil
    t.integer "acquired_crunch_ent_id",   :limit => 8
    t.string  "acquired_crunch_ent_name", :limit => nil
    t.date    "date_acquired"
    t.integer "amount",                   :limit => 8
  end

  create_table "crunch_competitors_fnl", :id => false, :force => true do |t|
    t.integer "crunch_ent_id"
    t.string  "crunch_ent_name",            :limit => 256
    t.integer "competitor_crunch_ent_id"
    t.string  "competitor_crunch_ent_name", :limit => 256
  end

  create_table "crunch_funding_fnl", :id => false, :force => true do |t|
    t.integer "funding_id",                      :null => false
    t.integer "crunch_ent_id",    :limit => 8
    t.string  "crunch_ent_name",  :limit => nil
    t.string  "investing_entity", :limit => nil
    t.text    "investing_cohort"
    t.integer "cohort_id"
    t.string  "round",            :limit => nil
    t.integer "cohort_amount",    :limit => 8
    t.date    "date_invested"
  end

  create_table "crunch_investments_fnl", :id => false, :force => true do |t|
    t.integer "investment_id",                            :null => false
    t.integer "investing_crunch_ent_id",   :limit => 8
    t.string  "investing_crunch_ent_name", :limit => nil
    t.integer "invested_crunch_ent_id",    :limit => 8
    t.string  "invested_crunch_ent_name",  :limit => nil
    t.date    "date_invested"
  end

  create_table "crunch_main_fnl", :id => false, :force => true do |t|
    t.integer "crunch_ent_id",                  :null => false
    t.string  "crunch_ent_name", :limit => nil
    t.string  "ticker",          :limit => nil
    t.integer "employees"
    t.date    "founded"
    t.string  "website",         :limit => nil
    t.string  "category",        :limit => nil
    t.text    "products"
    t.string  "description",     :limit => nil
    t.text    "blurb"
  end

  create_table "crunch_people_fnl", :id => false, :force => true do |t|
    t.integer "crunch_ent_id"
    t.string  "crunch_ent_name", :limit => 256
    t.string  "person",          :limit => 256
    t.string  "title",           :limit => 256
  end

  create_table "crunch_people_fnl111", :id => false, :force => true do |t|
    t.integer "crunch_ent_id"
    t.string  "crunch_ent_name", :limit => 256
    t.string  "person",          :limit => 256
    t.string  "title",           :limit => 256
  end

  create_table "docketx_document_inventory", :id => false, :force => true do |t|
    t.integer   "id"
    t.string    "file_location"
    t.string    "docket_case_number_long"
    t.string    "case_key"
    t.string    "document_date_filed"
    t.string    "document_date_entered"
    t.integer   "entry_number"
    t.string    "document_type"
    t.string    "pacer_document_url"
    t.string    "isocrd"
    t.string    "no_of_pages"
    t.float     "Size"
    t.string    "docketx_id"
    t.integer   "core_lit_document_id"
    t.string    "caseid"
    t.string    "de_seq_num"
    t.string    "dm_id"
    t.string    "doc_num"
    t.string    "pdf_header"
    t.timestamp "init_s3_move",            :limit => 6
    t.integer   "lit_document_type_id"
  end

  add_index "docketx_document_inventory", ["core_lit_document_id"], :name => "docketx_document_inventory_ix2"
  add_index "docketx_document_inventory", ["docketx_id"], :name => "docketx_document_inventory_ix1"

  create_table "ent_tree", :id => false, :force => true do |t|
    t.integer "my_pk",          :null => false
    t.integer "ent_id",         :null => false
    t.integer "related_ent_id", :null => false
  end

  create_table "entities", :id => false, :force => true do |t|
    t.string  "id",            :limit => 10,                    :null => false
    t.string  "entity_name",   :limit => 50,                    :null => false
    t.string  "bd_lead",       :limit => 25
    t.string  "cr_lead",       :limit => 25
    t.decimal "rate_card"
    t.boolean "member_flag",                 :default => false, :null => false
    t.date    "prospect_date"
  end

  create_table "lit_documents_002", :id => false, :force => true do |t|
    t.text    "doc_name"
    t.text    "documentid"
    t.text    "pacerid"
    t.text    "entrynumber"
    t.text    "url"
    t.integer "core_lit_documents_id"
  end

  add_index "lit_documents_002", ["core_lit_documents_id"], :name => "lit_documents_core_lit_documents_id_ix"

  create_table "lit_documents_002_nomatch", :id => false, :force => true do |t|
    t.text    "doc_name"
    t.text    "documentid"
    t.text    "pacerid"
    t.text    "entrynumber"
    t.text    "url"
    t.integer "core_lit_documents_id"
  end

  create_table "networking_lits_detailed_08223012", :id => false, :force => true do |t|
    t.integer "core_lit_id"
    t.string  "case_name"
    t.string  "normalized_defendant"
    t.integer "defendant_ent_id"
    t.text    "normalized_plaintiff_name"
    t.date    "original_date_filed"
    t.date    "defendant_terminated"
    t.integer "duration"
    t.text    "ps_tag"
    t.text    "named_product"
    t.integer "def_count",                 :limit => 8
    t.text    "rpx_member"
    t.text    "rpx_pat_co_def"
    t.integer "pat_co_def"
    t.integer "pat_count",                 :limit => 8
    t.text    "string_agg"
    t.text    "rpx_member_active"
    t.string  "patent_classification"
  end

  create_table "networking_lits_detailed_12132012", :id => false, :force => true do |t|
    t.integer "core_lit_id"
    t.string  "case_name"
    t.string  "normalized_defendant"
    t.integer "defendant_ent_id"
    t.text    "normalized_plaintiff_name"
    t.date    "original_date_filed"
    t.date    "defendant_terminated"
    t.integer "duration"
    t.text    "ps_tag"
    t.text    "named_product"
    t.integer "def_count",                 :limit => 8
    t.text    "rpx_member"
    t.text    "rpx_pat_co_def"
    t.integer "pat_co_def"
    t.integer "pat_count",                 :limit => 8
    t.text    "string_agg"
    t.text    "rpx_member_active"
    t.string  "patent_classification"
  end

  create_table "pat_class_codes", :id => false, :force => true do |t|
    t.integer "id"
    t.string  "class_code"
    t.text    "class_title"
    t.string  "sub_class_code"
    t.text    "sub_class_title"
  end

  create_table "patent_diff", :id => false, :force => true do |t|
    t.date    "date_"
    t.integer "core_cnt", :limit => 8
    t.integer "etl_cnt",  :limit => 8
    t.integer "diff",     :limit => 8
    t.text    "dow"
  end

  create_table "psacqs", :id => false, :force => true do |t|
    t.string "acquisition",         :limit => 240
    t.string "id",                  :limit => 18
    t.string "confidentiality"
    t.string "product_service_tag", :limit => 240
  end

  create_table "rails_test_table", :id => false, :force => true do |t|
    t.integer "id"
    t.integer "core_lit_id"
    t.string  "case_key",                      :limit => 32
    t.string  "full_rpx_lit_id",               :limit => 16
    t.text    "rpx_lit_id"
    t.text    "docket_number"
    t.string  "case_name"
    t.string  "case_type",                     :limit => 32
    t.integer "case_type_agg",                 :limit => 2
    t.integer "dj",                            :limit => 2
    t.string  "court",                         :limit => 60
    t.text    "judge"
    t.text    "normalized_plaintiff_name"
    t.string  "plaintiff_ent_ids",             :limit => nil
    t.string  "transferred",                   :limit => 1
    t.string  "original_lit_id",               :limit => 512
    t.string  "transferred_to",                :limit => 1023
    t.string  "transferred_from",              :limit => 512
    t.date    "original_date_filed"
    t.date    "date_filed"
    t.string  "active",                        :limit => 30
    t.date    "date_closed"
    t.string  "normalized_defendant"
    t.integer "defendant_ent_id"
    t.date    "defendant_started"
    t.date    "defendant_terminated"
    t.string  "market_sector"
    t.text    "patents"
    t.text    "plaintiff_as_listed_ent_names"
    t.string  "plaintiff_as_listed_ent_ids",   :limit => nil
    t.boolean "plaintiff_is_member"
    t.boolean "defendant_is_member"
  end

  create_table "rev_factset", :id => false, :force => true do |t|
    t.integer "factset_id",                   :null => false
    t.string  "factset_name",  :limit => 256
    t.string  "ticker_symbol", :limit => 64
    t.float   "revenue"
  end

  create_table "rev_hoov_04052012", :id => false, :force => true do |t|
    t.integer "ent_id"
    t.string  "ult_parent_name", :limit => nil
    t.string  "name",            :limit => 1024
    t.string  "factset_name",    :limit => nil
    t.string  "ticker_symbol"
    t.float   "revenue"
    t.string  "updated_by",      :limit => nil
    t.date    "date_updated"
    t.string  "revenue_source",  :limit => nil
    t.string  "is_verified",     :limit => nil
    t.integer "year_founded"
  end

# Could not dump table "rev_hoov_04052012_copy" because of following StandardError
#   Unknown type 'unknown' for column 'factset_name'

  create_table "revenue_models", :force => true do |t|
    t.string   "ent_id"
    t.string   "company"
    t.decimal  "revenue_mill"
    t.string   "source"
    t.datetime "updated_at",   :null => false
    t.string   "updated_by"
    t.boolean  "is_verified"
    t.datetime "created_at",   :null => false
  end

  create_table "revenue_table", :id => false, :force => true do |t|
    t.integer "revenue_id",                     :null => false
    t.integer "ent_id"
    t.string  "ult_parent_name", :limit => nil
    t.string  "name",            :limit => nil
    t.string  "factset_name",    :limit => nil
    t.string  "ticker_symbol"
    t.float   "revenue"
    t.string  "updated_by",      :limit => nil
    t.date    "date_updated"
    t.string  "revenue_source",  :limit => nil
    t.string  "is_verified",     :limit => nil
    t.integer "year_founded"
  end

  create_table "rpx_itc_casedata", :id => false, :force => true do |t|
    t.string "inv_no",          :limit => 12,  :null => false
    t.date   "date_opened"
    t.string "title"
    t.string "inv_type",        :limit => 132
    t.date   "date_terminated"
    t.string "status",          :limit => 12
    t.string "disposition",     :limit => 132
    t.string "npeflag",         :limit => 1
  end

  create_table "rpx_itc_parties", :id => false, :force => true do |t|
    t.string "inv_no",              :limit => 12
    t.string "party"
    t.string "party_type",          :limit => 11
    t.date   "party_terminated"
    t.date   "party_term_updated?"
  end

  create_table "rpx_members", :id => false, :force => true do |t|
    t.string  "rpx_ent_id", :limit => 50
    t.integer "ent_id"
    t.string  "name",       :limit => nil
  end

  create_table "temp_prospects_lits_list", :id => false, :force => true do |t|
    t.integer "defendant_ent_id"
    t.string  "normalized_defendant"
    t.text    "plaintiffs"
  end

# Could not dump table "temptab" because of following StandardError
#   Unknown type 'unknown' for column 'factset_name'

  create_table "tmp_crunch_acquisitions", :id => false, :force => true do |t|
    t.string  "crunch_ent_name",          :limit => 256
    t.string  "acquired_crunch_ent_name", :limit => 256
    t.date    "date_acquired"
    t.integer "amount",                   :limit => 8
  end

  create_table "tmp_crunch_competitors", :id => false, :force => true do |t|
    t.string "crunch_ent_name", :limit => 256
    t.string "competitor",      :limit => 256
  end

  create_table "tmp_crunch_funding", :id => false, :force => true do |t|
    t.string  "crunch_ent_name",  :limit => 256
    t.string  "investing_entity", :limit => 256
    t.text    "investing_cohort"
    t.integer "cohort_id"
    t.string  "round",            :limit => 256
    t.integer "cohort_amount",    :limit => 8
    t.date    "date_invested"
  end

  create_table "tmp_crunch_investments", :id => false, :force => true do |t|
    t.string "crunch_ent_name",          :limit => 256
    t.string "invested_crunch_ent_name", :limit => 256
    t.date   "date_invested"
  end

  create_table "tmp_crunch_main", :id => false, :force => true do |t|
    t.string  "crunch_ent_name", :limit => 256
    t.string  "ticker",          :limit => 64
    t.integer "employees"
    t.date    "founded"
    t.string  "website",         :limit => 256
    t.string  "category",        :limit => 32
    t.text    "products"
    t.string  "description",     :limit => 256
    t.text    "blurb"
  end

  create_table "tmp_crunch_people", :id => false, :force => true do |t|
    t.string "crunch_ent_name", :limit => 256
    t.string "person",          :limit => 256
    t.string "title",           :limit => 256
  end

  create_table "tmp_dov_ps_cases", :id => false, :force => true do |t|
    t.string "case_key", :limit => 32
  end

  add_index "tmp_dov_ps_cases", ["case_key"], :name => "ix1"

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
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "v_corr_part_trans", :id => false, :force => true do |t|
    t.boolean "partial_trans"
  end

  create_table "vw_pats_suits", :id => false, :force => true do |t|
    t.integer "id"
    t.integer "core_lit_id"
    t.string  "case_key",                  :limit => 32
    t.string  "full_rpx_lit_id",           :limit => 16
    t.text    "rpx_lit_id"
    t.text    "docket_number"
    t.string  "case_name"
    t.string  "case_type",                 :limit => 32
    t.integer "case_type_agg",             :limit => 2
    t.integer "dj",                        :limit => 2
    t.string  "court",                     :limit => 60
    t.text    "judge"
    t.text    "normalized_plaintiff_name"
    t.string  "plaintiff_ent_ids",         :limit => nil
    t.string  "transferred",               :limit => 1
    t.string  "original_lit_id"
    t.string  "transferred_to"
    t.string  "transferred_from"
    t.date    "original_date_filed"
    t.date    "date_filed"
    t.string  "active",                    :limit => 30
    t.date    "date_closed"
    t.string  "normalized_defendant"
    t.integer "defendant_ent_id"
    t.date    "defendant_started"
    t.date    "defendant_terminated"
    t.string  "market_sector"
    t.text    "patents"
    t.string  "patent2",                   :limit => nil
    t.text    "patent"
  end

end
