ActiveRecord::Base.extend ActiveRecord::Acts::Textcaptcha
ActionController::Base.include TextcaptchaHelper if defined? ActionController