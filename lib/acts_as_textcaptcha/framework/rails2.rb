ActiveRecord::Base.extend ActsAsTextcaptcha::Textcaptcha
ActionView::Base.send(:include, ActsAsTextcaptcha::TextcaptchaHelper)
