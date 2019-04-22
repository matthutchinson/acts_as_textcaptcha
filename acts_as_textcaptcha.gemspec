# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "acts_as_textcaptcha/version"

Gem::Specification.new do |spec|
  spec.name     = "acts_as_textcaptcha"
  spec.version  = ActsAsTextcaptcha::VERSION
  spec.authors  = ["Matthew Hutchinson"]
  spec.email    = ["matt@hiddenloop.com"]
  spec.homepage = "http://github.com/matthutchinson/acts_as_textcaptcha"
  spec.license  = 'MIT'
  spec.summary  = "A text-based logic question captcha for Rails"

  spec.description = <<-EOF
  ActsAsTextcaptcha provides spam protection for Rails models with text-based
  logic question captchas. Questions are fetched from Rob Tuley's
  textcaptcha.com They can be solved easily by humans but are tough for robots
  to crack.
  EOF

  spec.metadata = {
    "homepage_uri"    => "https://github.com/matthutchinson/acts_as_textcaptcha",
    "changelog_uri"   => "https://github.com/matthutchinson/acts_as_textcaptcha/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/matthutchinson/acts_as_textcaptcha",
    "bug_tracker_uri" => "https://github.com/matthutchinson/acts_as_textcaptcha/issues",
  }

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = `git ls-files -- {test}/*`.split("\n")
  spec.bindir        = "bin"
  spec.require_paths = ["lib"]

  # documentation
  spec.extra_rdoc_files = ["README.md", "LICENSE"]
  spec.rdoc_options << "--title" << "ActAsTextcaptcha" << "--main" << "README.md" << "-ri"

  # non-gem dependecies
  spec.required_ruby_version = ">= 2.3"

  # dev gems
  spec.add_development_dependency('bundler')
  spec.add_development_dependency "rake"
  spec.add_development_dependency('pry-byebug')

  # docs
  spec.add_development_dependency('rdoc')

  # testing
  spec.add_development_dependency('minitest')
  spec.add_development_dependency('rails', '~> 5.2.3')
  spec.add_development_dependency('sqlite3')
  spec.add_development_dependency('webmock')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('appraisal')
end
