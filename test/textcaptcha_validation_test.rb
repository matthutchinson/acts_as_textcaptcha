# frozen_string_literal: true

require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TextcaptchaValidationTest < Minitest::Test
  def setup
    note.textcaptcha
  end

  def test_validates_with_correct_answers
    assert_equal note.textcaptcha_question, "1+1"
    refute note.valid?
    assert_equal note.errors[:textcaptcha_answer].first, "is incorrect, try another question instead"

    note.textcaptcha_answer = "two"
    assert note.valid?
    assert note.errors[:textcaptcha_answer].empty?

    note.textcaptcha_answer = "2"
    assert note.valid?
    assert note.errors[:textcaptcha_answer].empty?
  end

  def test_strips_whitespace_and_downcases_answer_to_validate
    note.textcaptcha_answer = " tWo "
    assert note.valid?
    assert note.errors[:textcaptcha_answer].empty?
  end

  def test_is_always_valid_after_record_has_been_saved
    note.textcaptcha_answer = "2"
    note.save!
    note.textcaptcha

    note.textcaptcha_answer = "wrong answer"
    refute note.new_record?
    assert note.valid?
    assert_empty note.errors[:textcaptcha_answer]
  end

  def test_always_valid_when_perform_textcaptcha_is_false
    note.turn_off_captcha = true
    assert note.valid?
    assert_empty note.errors[:textcaptcha_answer]

    assert note.save
  end

  def test_validating_non_active_record_object
    contact = Contact.new
    contact.textcaptcha

    assert_equal contact.textcaptcha_question, "one+1"
    contact.textcaptcha_answer = "wrong"
    refute contact.valid?

    contact.textcaptcha_answer = "two"
    assert contact.valid?
    assert_empty contact.errors[:textcaptcha_answer]
  end

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

  def test_assigns_captcha_with_accessible_attr_widget
    widget = StrongAccessibleWidget.new
    widget.textcaptcha
    assert_equal widget.textcaptcha_question, "1+1"
    refute widget.valid?
  end

  def test_assigns_captcha_with_protected_attr_widget
    widget = StrongProtectedWidget.new
    widget.textcaptcha
    assert_equal widget.textcaptcha_question, "1+1"
    refute widget.valid?
  end

  private

  def note
    @note ||= Note.new
  end
end
