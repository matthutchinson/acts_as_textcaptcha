# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class NotesController < ActionController::Base; end

class ViewTemplate < ActionView::Base
  def protect_against_forgery?; false; end
end

class TextcaptchaHelperTest < Minitest::Test

  def setup
    note.textcaptcha
  end

  def test_renders_q_and_a_fields_with_hidden_key_field
    html = render_template

    assert_match(/\<label for\=\"note_textcaptcha_answer\"\>1\+1\<\/label\>/, html)
    assert_match(/\<input(.*)name\=\"note\[textcaptcha_answer\]\"(.*)\/\>/, html)
    assert_match(/\<input(.*)name\=\"note\[textcaptcha_key\]\"(.*)\/\>/, html)
  end

  def test_renders_only_hidden_answer_field_when_only_answer_present
    note.textcaptcha_question = nil
    note.textcaptcha_answer   = 2
    html = render_template

    refute_match(/\<label for\=\"note_textcaptcha_answer\"\>1\+1\<\/label\>/, html)
    assert_match(/\<input(.*)name\=\"note\[textcaptcha_answer\]\"(.*)\/\>/, html)
    assert_match(/\<input(.*)name\=\"note\[textcaptcha_key\]\"(.*)\/\>/, html)
  end

  def test_does_not_render_q_or_a_when_perform_textcaptcha_is_false
    note.turn_off_captcha = true
    html = render_template

    refute_match(/note_textcaptcha_answer/, html)
    refute_match(/note_textcaptcha_key/, html)
  end

  def test_does_not_render_q_or_a_when_key_is_missing
    note.textcaptcha_key = nil
    html = render_template

    refute_match(/note_textcaptcha_answer/, html)
    refute_match(/note_textcaptcha_key/, html)
  end

  private

    def note
      @note ||= Note.new
    end

    def render_template(assigns = { :note => @note })
     @controller ||= NotesController.new
      html_erb = <<-ERB
      <%= form_for(@note, :url => '/') do |f| %>
        <%= textcaptcha_fields(f) do %>
        <div class="field textcaptcha">
          <%= f.label :textcaptcha_answer, @note.textcaptcha_question %><br/>
          <%= f.text_field :textcaptcha_answer, :value => '' %>
        </div>
        <% end %>
      <% end %>
      ERB

      ViewTemplate.new([], assigns, @controller).render(inline: html_erb)
    end
end
