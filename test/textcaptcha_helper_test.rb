require File.expand_path(File.dirname(__FILE__)+'/test_helper')
require 'action_controller'
require 'action_view'

class NotesController < ActionController::Base; end

class Template < ActionView::Base
  def protect_against_forgery?; false; end
end


describe 'TextcaptchaHelper' do

  before(:each) do
    @controller = NotesController.new
    @note       = Note.new
    @note.textcaptcha
  end

  def render_template(assigns = { :note => @note })
    template = <<-ERB
    <%= form_for(@note, :url => '/') do |f| %>
      <%= textcaptcha_fields(f) do %>
      <div class="field textcaptcha">
        <%= f.label :textcaptcha_answer, @note.textcaptcha_question %><br/>
        <%= f.text_field :textcaptcha_answer, :value => '' %>
      </div>
      <% end %>
    <% end %>
    ERB

    Template.new([], assigns, @controller).render(:inline => template)
  end

  it 'should render question and answer fields, with hidden textcaptcha_key field' do
    html = render_template

    assert_match(/\<label for\=\"note_textcaptcha_answer\"\>1\+1\<\/label\>/, html)
    assert_match(/\<input value\=\"\" type\=\"text\" name\=\"note\[textcaptcha_answer\]\" id\=\"note_textcaptcha_answer\" \/\>/, html)
    assert_match(/\<input type\=\"hidden\" value\=\"([0-9a-f]{32})\" name\=\"note\[textcaptcha_key\]\" id\=\"note_textcaptcha_key\" \/\>/, html)
  end

  it 'should render hidden answer and textcaptcha_key when only answer is present' do
    @note.textcaptcha_question = nil
    @note.textcaptcha_answer   = 2
    html = render_template

    refute_match(/\<label for\=\"note_textcaptcha_answer\"\>1\+1\<\/label\>/, html)
    assert_match(/\<input type\=\"hidden\" value\=\"2\" name\=\"note\[textcaptcha_answer\]\" id\=\"note_textcaptcha_answer\" \/\>/, html)
    assert_match(/\<input type\=\"hidden\" value\=\"([0-9a-f]{32})\" name\=\"note\[textcaptcha_key\]\" id\=\"note_textcaptcha_key\" \/\>/, html)
  end

  it 'should not render any question or answer when perform_textcaptcha? is false' do
    @note.turn_off_captcha = true
    html = render_template

    refute_match(/note_textcaptcha_answer/, html)
    refute_match(/note_textcaptcha_key/, html)
  end

  it 'should not render any question or answer when textcaptcha_key is missing' do
    @note.textcaptcha_key = nil
    html = render_template

    refute_match(/note_textcaptcha_answer/, html)
    refute_match(/note_textcaptcha_key/, html)
  end
end
