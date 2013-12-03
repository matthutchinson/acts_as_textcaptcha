# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "acts_as_textcaptcha/version"

Gem::Specification.new do |s|
  s.name        = "acts_as_textcaptcha"
  s.version     = ActsAsTextcaptcha::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matthew Hutchinson"]
  s.email       = ["matt@hiddenloop.com"]
  s.homepage    = "http://github.com/matthutchinson/acts_as_textcaptcha"
  s.summary     = %q{Spam protection for your models via logic questions and the textcaptcha.com API}
  s.description = %q{Simple question/answer based spam protection for your Rails models.
  You can define your own logic questions and/or fetch questions from the textcaptcha.com API.
  The questions involve human logic and are tough for spam bots to crack.
  For more reasons on why logic questions are a good idea visit; http://textcaptcha.com/why}

  s.extra_rdoc_files = ['README.rdoc', 'LICENSE']

  s.cert_chain  = ['gem-public_cert.pem']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency('bcrypt-ruby', '~> 3.0.1')

  s.add_development_dependency('rails')
  s.add_development_dependency('bundler')
  s.add_development_dependency('minitest')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('sqlite3')
  s.add_development_dependency('fakeweb')
  s.add_development_dependency('strong_parameters')
  s.add_development_dependency('coveralls')
end
