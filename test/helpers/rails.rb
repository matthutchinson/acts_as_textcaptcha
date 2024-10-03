# frozen_string_literal: true

require "rails/all"

# init cache, StringIO logger, and test models/db
LOGGER_IO = StringIO.new
Rails.logger = Logger.new(LOGGER_IO)
Rails.cache = ActiveSupport::Cache::MemoryStore.new

# set Rails test env
ENV["RAILS_ENV"] = "test"

# initialize db with schema
FileUtils.mkdir_p "./tmp"
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "tmp/acts_as_textcaptcha_test.sqlite3.db")
load(File.expand_path("#{File.dirname(__FILE__)}/../schema.rb"))
