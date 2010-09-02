ENV["RAILS_ENV"] ||= 'test'

require 'rubygems'
require 'active_record'
require 'rails' 
require 'spec'
require 'spec/autorun'   

require File.dirname(__FILE__) + '/../lib/acts_as_textcaptcha'

ActiveRecord::Base.establish_connection(YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))[ENV['DB'] || 'sqlite3'])

load(File.dirname(__FILE__) + "/schema.rb")
