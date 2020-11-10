# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rdoc/task"
require "rubocop/rake_task"

# generate docs
RDoc::Task.new do |rd|
  rd.main = "README.md"
  rd.title = "ActsAsTextcaptcha"
  rd.rdoc_dir = "doc"
  rd.options << "--all"
  rd.rdoc_files.include("README.md", "LICENSE", "lib/**/*.rb")
end

# run tests
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

# run lint
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ["--display-cop-names"]
end

# run tests with code coverage (default)
namespace :test do
  desc "Run all tests and features and generate a code coverage report"
  task :coverage do
    ENV["COVERAGE"] = "true"
    Rake::Task["test"].execute
    Rake::Task["rubocop"].execute
  end
end

task default: [:rubocop, "test:coverage"]
