module ActsAsTextcaptcha
  module TextcaptchaHelper

    # builds html fields for spam question, answer and hidden encrypted answers
    def textcaptcha_fields(f, &block)
      model        = f.object
      captcha_html = ''
      if model.perform_textcaptcha?
         captcha_html += f.hidden_field(:spam_answers)
         if model.spam_answer
           captcha_html += f.hidden_field(:spam_answer)
         elsif model.spam_question
           captcha_html += capture(&block)
         end
      end
      if Rails::VERSION::MAJOR < 3
        concat captcha_html, &block.binding
      else
        captcha_html.html_safe
      end
    end
  end
end
