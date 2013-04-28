$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)+'./../lib'))

ENV['RAILS_ENV'] = 'test'

if ENV['COVERAGE']
  require "simplecov"
  SimpleCov.start do
    add_filter '/test/'
  end
  SimpleCov.at_exit do
    SimpleCov.result.format!
    `open ./coverage/index.html` if RUBY_PLATFORM =~ /darwin/
  end
end

require 'minitest/autorun'
require 'fakeweb'

require 'rails/all'

require 'acts_as_textcaptcha'
require './test/test_models'

# load and initialize test db schema
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => 'acts_as_textcaptcha.sqlite3.db')
load(File.dirname(__FILE__) + "/schema.rb")
