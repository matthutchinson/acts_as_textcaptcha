SimpleCov.start do
  add_filter '/test/'
  add_filter '/vendor/'
end

SimpleCov.at_exit do
  SimpleCov.result.format!
  `open ./coverage/index.html` if RUBY_PLATFORM =~ /darwin/
end
