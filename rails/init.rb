ActiveRecord::Base.extend ActiveRecord::Acts::Textcaptcha
ActionController::Base.send :include, TextcaptchaHelper if defined? ActionController