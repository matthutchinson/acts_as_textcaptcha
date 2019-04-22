# frozen_string_literal: true

module ActsAsTextcaptcha
  module TextcaptchaHelper

    def textcaptcha_fields(f, &block)
      if f.object.perform_textcaptcha? && f.object.textcaptcha_key
        build_textcaptcha_form_elements(f, &block)
      end
    end

    private

      def build_textcaptcha_form_elements(f, &block)
        captcha_html = f.hidden_field(:textcaptcha_key)
        if f.object.textcaptcha_question
          captcha_html += capture(&block)
        elsif f.object.textcaptcha_answer
          captcha_html += f.hidden_field(:textcaptcha_answer)
        end
        captcha_html.html_safe
      end
  end
end
