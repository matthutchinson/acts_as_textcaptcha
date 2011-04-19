gem 'rdoc'

require 'bundler'
require 'rdoc/task'
require 'rspec/core/rake_task'
require 'rcov/rcovtask'

# bundler tasks
Bundler::GemHelper.install_tasks

# rspec tasks
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--color --format=doc"
end

# rdoc tasks
RDoc::Task.new do |rd|
  rd.main     = "README.rdoc"
  rd.title    = 'acts_as_textcaptcha'
  rd.rdoc_dir = 'doc'
  rd.options  << "--all"
  rd.rdoc_files.include("README.rdoc", "LICENSE", "lib/**/*.rb")
end