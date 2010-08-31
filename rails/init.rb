require 'acts_as_textcaptcha'

# compatiblity with < Rails 3.0.0
unless defined?(Rails::Railtie)
  if defined?(::ActiveRecord::Base)
    ::ActiveRecord::Base.extend ActsAsTextcaptcha
  end

  if defined?(::ActionController::Base)
    ::ActionController::Base.send(:include, TextcaptchaHelper)
  end
end