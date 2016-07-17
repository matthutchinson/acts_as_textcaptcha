# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "acts_as_textcaptcha/version"

Gem::Specification.new do |s|
  s.name        = "acts_as_textcaptcha"
  s.version     = ActsAsTextcaptcha::VERSION
  s.authors     = ["Matthew Hutchinson"]
  s.email       = ["matt@hiddenloop.com"]
  s.homepage    = "http://github.com/matthutchinson/acts_as_textcaptcha"
  s.license     = 'MIT'
  s.summary     = %q{Spam protection for your models via logic questions and the textcaptcha.com API}

  s.description = %q{Simple question/answer based spam protection for your Rails models.
  You can define your own logic questions and/or fetch questions from the textcaptcha.com API.
  The questions involve human logic and are tough for spam bots to crack.
  For more reasons on why logic questions are a good idea visit; http://textcaptcha.com/why}

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # 'allowed_push_host' to allow pushing to a single host or delete this section
  # to allow pushing to any host.
  if s.respond_to?(:metadata)
    s.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.require_paths = ["lib"]

  # always test against latest rails version
  s.add_development_dependency('rails', '~> 5.0.0')

  s.add_development_dependency('mime-types')
  s.add_development_dependency('bundler')
  s.add_development_dependency('minitest')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('sqlite3')
  s.add_development_dependency('webmock')
  s.add_development_dependency('coveralls')
end
