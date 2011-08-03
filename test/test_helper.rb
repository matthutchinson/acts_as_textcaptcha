$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)+'./../lib'))

ENV['RAILS_ENV'] = 'test'

require 'minitest/autorun'
require 'fakeweb'

require 'active_record'
require 'rails'

require 'bcrypt'
require 'acts_as_textcaptcha'

# load and initialize test db schema
ActiveRecord::Base.establish_connection(YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))[ENV['DB'] || 'sqlite3'])
load(File.dirname(__FILE__) + "/schema.rb")
