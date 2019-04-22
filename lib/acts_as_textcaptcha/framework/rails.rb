# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do
  extend ActsAsTextcaptcha::Textcaptcha
end

ActiveSupport.on_load(:action_view) do
  include ActsAsTextcaptcha::TextcaptchaHelper
end
