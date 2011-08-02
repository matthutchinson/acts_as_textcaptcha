gem 'rdoc'

require 'bundler'
require 'rdoc/task'
require 'rake/testtask'
require 'rcov/rcovtask'

# bundler tasks
Bundler::GemHelper.install_tasks

# run all tests
Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end

# rdoc tasks
RDoc::Task.new do |rd|
  rd.main     = "README.rdoc"
  rd.title    = 'acts_as_textcaptcha'
  rd.rdoc_dir = 'doc'
  rd.options  << "--all"
  rd.rdoc_files.include("README.rdoc", "LICENSE", "lib/**/*.rb")
end
