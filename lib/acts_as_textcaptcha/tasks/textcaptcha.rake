# frozen_string_literal: true

require "rails"
require "acts_as_textcaptcha/textcaptcha_config"

namespace :textcaptcha do
  desc "Creates an example textcaptcha config at config/textcaptcha.yml"
  task :config do
    path = File.join((Rails.root || "."), "config", "textcaptcha.yml")
    if File.exist?(path)
      puts "Ooops, a textcaptcha config file at #{path} already exists ... aborting."
    else
      ActsAsTextcaptcha::TextcaptchaConfig.create(path: path)
      puts "Done, config generated at #{path}\nEdit this file to add your TextCaptcha API key (see https://textcaptcha.com)."
    end
  end
end
