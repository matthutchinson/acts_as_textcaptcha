gem 'rdoc'

# default rake
task :default => [:test]

# helpful console
desc "Irb console that requires this gem"
task :console do
  require 'irb'
  require 'irb/completion'
  require 'acts_as_textcaptcha'
  ARGV.clear
  IRB.start
end


# bundler tasks
require 'bundler'
Bundler::GemHelper.install_tasks

# run all tests
require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end

# code coverage
namespace :test do
  desc "Run all tests and generate a code coverage report (simplecov)"
  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task['test'].execute
  end
end

# rdoc tasks
require 'rdoc/task'
RDoc::Task.new do |rd|
  rd.main     = "README.rdoc"
  rd.title    = 'acts_as_textcaptcha'
  rd.rdoc_dir = 'doc'
  rd.options  << "--all"
  rd.rdoc_files.include("README.rdoc", "LICENSE", "lib/**/*.rb")
end
