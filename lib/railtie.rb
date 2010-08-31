require 'acts_as_textcaptcha'
require 'textcaptcha_helper'
require 'rails'

module ActsAsTextcaptcha
  class Railtie < Rails::Railtie
    config.after_initialize do
      if defined?(::ActiveRecord::Base)
        ::ActiveRecord::Base.extend ActsAsTextcaptcha
      end

      if defined?(::ActionController::Base)
        ::ActionController::Base.send(:include, TextcaptchaHelper)
      end
    end
  end
end