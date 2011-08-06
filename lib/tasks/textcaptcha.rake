require 'bcrypt'

namespace :textcaptcha do

  desc "Creates a template config file in config/textcaptcha.yml"
  task :config do
    src  = File.join(File.dirname(__FILE__), '../..', 'config', 'textcaptcha.yml')
    dest = File.join(Rails.root, 'config', 'textcaptcha.yml')
    if File.exist?(dest)
      puts "\nOoops, a textcaptcha config file at #{dest} already exists ... aborting.\n\n"
    else
      config = ''
      salt   = BCrypt::Engine.generate_salt
      f = File.open(src, 'r')
      f.each_line { |line| config += line }
      config.gsub!(/RAKE_GENERATED_SALT_PLACEHOLDER/, salt)
      config.gsub!(/  api_key:(.*)# for gem test purposes only$/, "  api_key: PASTE_YOUR_TEXTCAPCHA_API_KEY_HERE")
      config.gsub!(/  bcrypt_salt:(.*)# for gem test purposes only$/, "  bcrypt_salt: #{salt}")

      f = File.new(dest, 'w')
      f.write(config)
      f.close
      puts "\ntextcaptcha.yml generated at #{dest} (with a new BCrypt salt)\nNOTE: edit this file and add your textcaptcha api key, grab one from http://textcaptcha.com/api\n\n"
    end
  end
end
