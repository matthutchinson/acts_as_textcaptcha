namespace :textcaptcha do
  desc "Adds a textcaptcha.yml template config file to ./config "
  task :generate_config do

    src  = File.join(File.dirname(__FILE__), '../..', 'config', 'textcaptcha.yml')
    dest = File.join(Rails.root, 'config', 'textcaptcha.yml')
    if File.exist?(dest)
      puts "\ntextcaptcha config file: #{dest}\n ... already exists.  Aborting.\n\n"
    else
      config_file = ''
      f = File.open(src, 'r')
      f.each_line { |line| config_file += line }
      config_file.gsub!(/api\_key\:(.+)$/, 'api_key: # get one at http://textcaptcha.com' )
      config_file.gsub!(/bcrypt\_salt\:(.+)$/, "bcrypt_salt: #{BCrypt::Engine.generate_salt}" ) if defined?(BCrypt)

      f = File.new(dest, 'w')
      f.write(config_file)
      f.close
      puts "\ntextcaptcha.yml generated at #{dest} (with a new BCrypt salt).\nNOTE: edit this file and add your textcaptcha api key (from http://textcaptcha.com)"
    end

  end
end