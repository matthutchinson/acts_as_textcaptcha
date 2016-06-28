gem 'rdoc'

require 'bundler/gem_tasks'
require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => [:test]

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
  rd.main     = "README.md"
  rd.title    = 'acts_as_textcaptcha'
  rd.rdoc_dir = 'doc'
  rd.options  << "--all"
  rd.rdoc_files.include("README.md", "LICENSE.txt", "lib/**/*.rb")
end
