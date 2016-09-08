$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)+'./../lib/acts_as_textcaptcha'))

ENV['RAILS_ENV'] = 'test'

# confgure test coverage reporting
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/test/'
    add_filter '/vendor/'
  end
  SimpleCov.at_exit do
    SimpleCov.result.format!
    `open ./coverage/index.html` if RUBY_PLATFORM =~ /darwin/
  end
elsif ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end

require 'minitest/autorun'
require 'webmock/minitest'

require 'rails/all'

require 'acts_as_textcaptcha'
require './test/test_models'

# load and initialize test db schema
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => 'tmp/test_db/acts_as_textcaptcha.sqlite3.db')
load(File.dirname(__FILE__) + "/schema.rb")

# initialize the Rails cache (use a basic memory store in tests)
if Rails.version >= '4'
  Rails.cache = ActiveSupport::Cache::MemoryStore.new
else
  RAILS_CACHE = ActiveSupport::Cache::MemoryStore.new
end

# additional helper methods for use in tests
def find_in_cache(key)
  Rails.cache.read("#{ActsAsTextcaptcha::TextcaptchaCache::CACHE_KEY_PREFIX}#{key}")
end
