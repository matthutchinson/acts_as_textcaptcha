require "bundler/gem_tasks"
require "rake/testtask"
require "rdoc/task"

# generate docs
RDoc::Task.new do |rd|
  rd.main = "README.md"
  rd.title = "ActsAsTextcaptcha"
  rd.rdoc_dir = "doc"
  rd.options << "--all"
  rd.rdoc_files.include("README.md", "LICENSE", "lib/**/*.rb", "config/**/*.yml")
end

# run tests
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: [ "test" ]
