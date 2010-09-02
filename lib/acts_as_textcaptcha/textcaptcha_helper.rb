module ActsAsTextcaptcha
  module TextcaptchaHelper

    # generates a spam question and possible answers for a model, answers are stored in  session[:possible_answers]
    def spamify(model)
      session[:possible_answers] = model.generate_spam_question unless model.validate_spam_answer
    end
  end
end