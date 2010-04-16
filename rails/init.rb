require 'acts_as_textcaptcha'             

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend ActsAsTextcaptcha
end

if defined?(ActionController::Base)
  ActionController::Base.send :include, TextcaptchaHelper
end