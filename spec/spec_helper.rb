require 'rubygems'
require 'spec'
require 'active_record'

require File.dirname(__FILE__) + '/../lib/acts_as_textcaptcha'
require File.dirname(__FILE__) + '/../init.rb'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])

load(File.dirname(__FILE__) + "/schema.rb")
