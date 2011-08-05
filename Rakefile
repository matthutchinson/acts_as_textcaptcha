gem 'rdoc'

# default rake
task :default => [:test]

# bundler tasks
require 'bundler'
Bundler::GemHelper.install_tasks

# run all tests
require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end

# code coverage
namespace :cover_me do
  desc "Generates and opens code coverage report."
  task :report do
    require 'cover_me'
    CoverMe.config.project.root = File.expand_path('../', __FILE__)
    CoverMe.config.file_pattern = [/.*\.rb/i]
    Rake::Task['test'].invoke
    CoverMe.complete!
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
