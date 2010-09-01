require 'acts_as_textcaptcha'
require 'textcapcha_helper'

ActiveSupport.on_load(:active_record) do
  extend ActsAsTextcaptcha
end

ActiveSupport.on_load(:action_controller) do
  include TextcaptchaHelper
end