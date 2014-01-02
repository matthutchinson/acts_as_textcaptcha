module ActsAsTextcaptcha
  module TextcaptchaHelper

    # builds html form fields for the textcaptcha
    def textcaptcha_fields(f, &block)
      model        = f.object
      captcha_html = ''
      if model.perform_textcaptcha?
        if model.textcaptcha_key
          captcha_html += f.hidden_field(:textcaptcha_key)
          if model.textcaptcha_question
            captcha_html += capture(&block)
          elsif model.textcaptcha_answer
            captcha_html += f.hidden_field(:textcaptcha_answer)
          end
        end
      end

      captcha_html.html_safe
    end
  end
end
