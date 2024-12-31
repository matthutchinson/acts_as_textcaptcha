# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "acts_as_textcaptcha/version"

Gem::Specification.new do |spec|
  spec.name     = "acts_as_textcaptcha"
  spec.version  = ActsAsTextcaptcha::VERSION
  spec.authors  = [ "Matthew Hutchinson" ]
  spec.email    = [ "matt@hiddenloop.com" ]
  spec.homepage = "http://github.com/matthutchinson/acts_as_textcaptcha"
  spec.license  = "MIT"
  spec.summary  = "A text-based logic question captcha for Rails"
  spec.files    = Dir["lib/**/*", "config/**/*", "LICENSE", "README.md"]

  spec.require_paths = [ "lib" ]

  spec.required_ruby_version = ">= 3.1"
  spec.extra_rdoc_files = [ "README.md", "LICENSE" ]
  spec.rdoc_options << "--title" << "ActAsTextcaptcha" << "--main" << "README.md" << "-ri"

  spec.description = <<-DESCRIPTION
  ActsAsTextcaptcha provides spam protection for Rails models with text-based
  logic question captchas. Questions are fetched from Rob Tuley's
  textcaptcha.com They can be solved easily by humans but are tough for robots
  to crack.
  DESCRIPTION

  spec.metadata = {
    "homepage_uri" => "https://github.com/matthutchinson/acts_as_textcaptcha",
    "documentation_uri" => "https://rubydoc.info/gems/acts_as_textcaptcha",
    "changelog_uri" => "https://github.com/matthutchinson/acts_as_textcaptcha/blob/master/CHANGELOG.md",
    "bug_tracker_uri" => "https://github.com/matthutchinson/acts_as_textcaptcha/issues",
    "allowed_push_host" => "https://rubygems.org"
  }

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rdoc"
  spec.add_development_dependency "rails", "~> 8.0.1"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "webmock"
end
