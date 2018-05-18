require 'rails'
require 'acts_as_textcaptcha/textcaptcha_config'

namespace :textcaptcha do

  desc "Creates an example textcaptcha config at config/textcaptcha.yml"
  task :config do
    dest = File.join((Rails.root ? Rails.root : '.'), 'config', 'textcaptcha.yml')
    if File.exist?(dest)
      puts "Ooops, a textcaptcha config file at #{dest} already exists ... aborting."
    else
      ActsAsTextcaptcha::TextcaptchaConfig.create_yml_file(dest)
      puts "Done, config generated at #{dest}\nEdit this file to add your TextCaptcha API key (see http://textcaptcha.com)."
    end
  end
end
