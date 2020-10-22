# frozen_string_literal: true

require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TextcaptchaTest < Minitest::Test
  def test_answer_submitted_after_expiry_time
    comment = FastComment.new
    comment.textcaptcha
    assert_equal comment.textcaptcha_question, "1+1"
    comment.textcaptcha_answer = "two"
    sleep(0.01)

    refute comment.valid?
    assert_equal comment.errors[:textcaptcha_answer].first,
                 "was not submitted quickly enough, try another question instead"
  end

  def test_fetches_q_and_a_from_api
    stub_api_with(valid_json_response)

    review = Review.new
    review.textcaptcha
    refute_equal review.textcaptcha_question, "The green hat is what color?"
    refute_nil review.textcaptcha_question

    refute_nil find_in_cache(review.textcaptcha_key)

    refute review.valid?
    assert_equal review.errors[:textcaptcha_answer].first,
                 "is incorrect, try another question instead"
  end

  def test_parses_answers_from_json_response
    review = Review.new
    stub_api_with(valid_json_response)

    review.textcaptcha
    assert_equal review.textcaptcha_question, "What is Jennifer\'s name?"
    assert_equal find_in_cache(review.textcaptcha_key).length, 1
  end

  def test_assigns_user_defined_question_when_api_fetch_returns_nil
    stub_request(:get, "http://textcaptcha.com/api_key.json")
      .and_return(body: "")

    review = Review.new
    review.textcaptcha
    assert_equal review.textcaptcha_question, "The green hat is what color?"
    refute_nil find_in_cache(review.textcaptcha_key)
  end

  def test_assigns_no_q_and_a_when_no_user_defined_question_set_and_api_fails
    stub_request(:get, "http://textcaptcha.com/api_key.json")
      .to_raise(SocketError)

    comment = Comment.new
    comment.textcaptcha
    assert_nil comment.textcaptcha_question
    assert_nil comment.textcaptcha_key
  end

  def test_assigns_no_q_and_a_when_user_defined_question_set_incorrectly_and_api_fails
    stub_request(:get, "http://textcaptcha.com/api_key.json")
      .to_raise(SocketError)

    comment = MovieReview.new
    comment.textcaptcha
    assert_nil comment.textcaptcha_question
    assert_nil comment.textcaptcha_key
  end

  def test_configuration_with_hash
    assert_equal Review.textcaptcha_config, {
      api_key: "api_key",
      questions: [
        { question: "The green hat is what color?", answers: "green" }
      ]
    }
  end

  def test_configuration_with_textcaptcha_yml
    assert_equal Widget.textcaptcha_config[:api_key], "TEST_TEXTCAPTCHA_API_IDENT"
    assert_equal Widget.textcaptcha_config[:questions].length, 10
  end

  def test_raises_error_when_config_is_missing
    YAML.stub :load, -> { raise "bad things" } do
      exception = assert_raises(ArgumentError) do
        # using eval here, sorry :(
        eval <<-CLASS
          class SomeWidget < ApplicationRecord
            acts_as_textcaptcha
          end
        CLASS
      end
      assert_match(/could not find any textcaptcha options/, exception.message)
    end
  end
end
