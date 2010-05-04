# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require 'rubygems'
require 'spec'
require 'active_record'
require 'spec/autorun'

# Uncomment the next line to use webrat's matchers
#require 'webrat/integrations/rspec-rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

require File.dirname(__FILE__) + '/../lib/acts_as_textcaptcha'
require File.dirname(__FILE__) + '/../init.rb'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])

load(File.dirname(__FILE__) + "/schema.rb")
