require 'bundler'
require 'active_record'
require 'rails'
require 'acts_as_textcaptcha'

# setup db
ActiveRecord::Base.establish_connection(YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))[ENV['DB'] || 'sqlite3'])
load(File.dirname(__FILE__) + "/schema.rb")