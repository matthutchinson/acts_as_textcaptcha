ActiveRecord::Base.extend ActsAsTextcaptcha::Textcaptcha
ActionController::Base.send(:include, ActsAsTextcaptcha::TextcaptchaHelper)