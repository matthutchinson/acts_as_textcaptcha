Gem::Specification.new do |s|
  s.name = %q{acts_as_textcaptcha}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Hutchinson"]
  s.date = %q{2010-04-16}
  s.description = %q{Spam protection for your ActiveRecord models using logic questions and the excellent textcaptcha api. See textcaptcha.com for more details and to get your api key.
The logic questions are aimed at a child's age of 7, so can be solved easily by all but the most cognitively impaired users. As they involve human logic, such questions cannot be solved by a robot.
For more reasons on why logic questions are useful, see here; http://textcaptcha.com/why }
  s.email = %q{matt@hiddenloop.com}
  s.extra_rdoc_files = ['README.rdoc', 'LICENSE']
  s.files = [    
    'LICENSE',
    'README.rdoc',
    'Rakefile',
    'config/textcaptcha.yml',
    'init.rb',
    'lib/active_record/acts/textcaptcha.rb',
    'lib/textcaptcha_helper.rb',
    'spec/acts_as_textcaptcha_spec.rb',
    'spec/database.yml',
    'spec/schema.rb',
    'spec/spec.opts',
    'spec/spec_helper.rb'
  ]
  s.homepage = %q{http://github.com/hiddenloop/acts_as_textcaptcha}
  s.rdoc_options = ["--charset=UTF-8 --line-numbers --inline-source"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{spam protection for your models via logic questions and the excellent textcaptcha.com api}
  s.test_files = [
    "spec/spec_helper.rb",
    "spec/acts_as_textcaptcha_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end