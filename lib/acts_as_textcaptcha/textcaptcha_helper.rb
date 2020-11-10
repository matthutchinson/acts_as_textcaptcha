# frozen_string_literal: true

module ActsAsTextcaptcha
  module TextcaptchaHelper
    def textcaptcha_fields(form, &block)
      build_textcaptcha_form_elements(form, &block) if form.object.perform_textcaptcha? && form.object.textcaptcha_key
    end

    private

    def build_textcaptcha_form_elements(form, &block)
      captcha_html = form.hidden_field(:textcaptcha_key)
      if form.object.textcaptcha_question
        captcha_html += capture(&block)
      elsif form.object.textcaptcha_answer
        captcha_html += form.hidden_field(:textcaptcha_answer)
      end
      captcha_html.html_safe
    end
  end
end
