require 'acts_as_textcaptcha'
require 'textcapcha_helper'

ActiveRecord::Base.extend ActsAsTextcaptcha
ActionController::Base.send(:include, TextcaptchaHelper)