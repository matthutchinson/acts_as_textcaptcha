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
  s.summary     = %q{Spam protection for your models via logic questions and the excellent textcaptcha.com api}
  s.description = %q{Spam protection for your ActiveRecord models using logic questions and the excellent textcaptcha api. See textcaptcha.com for more details and to get your api key.
  The logic questions are aimed at a child's age of 7, so can be solved easily by all but the most cognitively impaired users. As they involve human logic, such questions cannot be solved by a robot.
  For more reasons on why logic questions are useful, see here; http://textcaptcha.com/why}

  s.extra_rdoc_files = ['README.rdoc', 'LICENSE']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('bcrypt-ruby', '~> 2.1.2')

  s.add_dependency('rails')
  s.add_dependency('activerecord')

  s.add_development_dependency('rspec', '~> 2.5.0')
  s.add_development_dependency('rcov', '~> 0.9.9')
  s.add_development_dependency('rdoc', '~> 3.5.3')
  s.add_development_dependency('sqlite3')
end
