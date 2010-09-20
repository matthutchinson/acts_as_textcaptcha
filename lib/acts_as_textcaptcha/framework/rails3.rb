ActiveSupport.on_load(:active_record) do
  extend ActsAsTextcaptcha::Textcaptcha
end

ActiveSupport.on_load(:action_controller) do
  include ActsAsTextcaptcha::TextcaptchaHelper
end                                                           