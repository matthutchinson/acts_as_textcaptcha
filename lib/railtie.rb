require 'acts_as_textcaptcha'
require 'rails'

module ActsAsTextcaptcha
  class Railtie < Rails::Railtie
    railtie_name :acts_as_textcaptcha
  end
end