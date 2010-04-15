module TextcaptchaHelper

  def spamify(model)
    session[:possible_answers] = model.generate_spam_question unless model.validate_spam_answer
  end
end
