require 'rubygems'
require 'bundler/gem_tasks'
require 'rake/testtask'

gem 'rdoc'

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => [:test]

# rdoc tasks
require 'rdoc/task'
RDoc::Task.new do |rd|
  rd.main     = "README.md"
  rd.title    = 'acts_as_textcaptcha'
  rd.rdoc_dir = 'doc'
  rd.options  << "--all"
  rd.rdoc_files.include("README.md", "LICENSE.txt", "lib/**/*.rb")
end
