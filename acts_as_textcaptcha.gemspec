# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "acts_as_textcaptcha/version"

Gem::Specification.new do |spec|
  spec.name = "acts_as_textcaptcha"
  spec.version = ActsAsTextcaptcha::VERSION
  spec.authors = ["Matthew Hutchinson"]
  spec.email = ["matt@hiddenloop.com"]
  spec.homepage = "http://github.com/matthutchinson/acts_as_textcaptcha"
  spec.license = "MIT"
  spec.summary = "A text-based logic question captcha for Rails"

  spec.description = <<-DESCRIPTION
  ActsAsTextcaptcha provides spam protection for Rails models with text-based
  logic question captchas. Questions are fetched from Rob Tuley's
  textcaptcha.com They can be solved easily by humans but are tough for robots
  to crack.
  DESCRIPTION

  spec.metadata = {
    "homepage_uri" => "https://github.com/matthutchinson/acts_as_textcaptcha",
    "changelog_uri" => "https://github.com/matthutchinson/acts_as_textcaptcha/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/matthutchinson/acts_as_textcaptcha",
    "bug_tracker_uri" => "https://github.com/matthutchinson/acts_as_textcaptcha/issues",
    "allowed_push_host" => "https://rubygems.org"
  }

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files = `git ls-files -- {test}/*`.split("\n")
  spec.bindir = "bin"
  spec.require_paths = ["lib"]

  # documentation
  spec.extra_rdoc_files = ["README.md", "LICENSE"]
  spec.rdoc_options << "--title" << "ActAsTextcaptcha" << "--main" << "README.md" << "-ri"

  # non-gem dependecies
  spec.required_ruby_version = ">= 2.5"

  # dev gems
  spec.add_development_dependency("bundler")
  spec.add_development_dependency("pry-byebug")
  spec.add_development_dependency "rake"

  # Lint
  spec.add_development_dependency("rubocop")

  # docs
  spec.add_development_dependency("rdoc")

  # testing
  spec.add_development_dependency("appraisal")
  spec.add_development_dependency("minitest")
  spec.add_development_dependency("rails", "~> 6.0.3.4")
  spec.add_development_dependency("simplecov", "~> 0.19.1")
  spec.add_development_dependency("sqlite3")
  spec.add_development_dependency("webmock")
end
