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
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'minitest/autorun'
require 'fakeweb'

require 'rails/all'

require 'acts_as_textcaptcha'
require './test/test_models'

# load and initialize test db schema
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => 'acts_as_textcaptcha.sqlite3.db')
load(File.dirname(__FILE__) + "/schema.rb")

# initialize a Rails.cache (use a basic memory store in tests)
Rails.cache = ActiveSupport::Cache::MemoryStore.new

# additional helper methods for use in tests
def find_in_cache(key)
  Rails.cache.read("#{ActsAsTextcaptcha::TextcaptchaCache::CACHE_KEY_PREFIX}#{key}")
end
