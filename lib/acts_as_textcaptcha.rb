require 'acts_as_textcaptcha/textcaptcha'
require 'acts_as_textcaptcha/textcaptcha_helper'
require "acts_as_textcaptcha/framework/rails#{Rails::VERSION::MAJOR < 3 ? 2 : nil}" if defined?(Rails)
