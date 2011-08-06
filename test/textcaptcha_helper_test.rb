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

  def render_template(assigns)
    template = <<-ERB
    <%= form_for(@note, :url => '/') do |f| %>
      <%= textcaptcha_fields(f) do %>
      <div class="field textcaptcha">
        <%= f.label :spam_answer, @note.spam_question %><br/>
        <%= f.text_field :spam_answer, :value => '' %>
      </div>
      <% end %>
    <% end %>
    ERB

    Template.new([], assigns, @controller).render(:inline => template)
  end

  it 'should render question and answer fields, with hidden spam_answers field' do
    html = render_template({:note => @note})

    html.must_match /\<label for\=\"note\_spam\_answer\"\>1\+1\<\/label\>/
    html.must_match /\<input id\=\"note_spam_answers\" name\=\"note\[spam\_answers\]\" type\=\"hidden\" value\=\"(.*)\" \/\>/
  end

  it 'should render hidden answer and spam_answer fields when question has been answered OK (and not ask question)' do
    @note.spam_answer = 2
    html = render_template({:note => @note})

    html.wont_match /\<label for\=\"note\_spam\_answer\"\>1\+1\<\/label\>/
    html.must_match /\<input id\=\"note_spam_answers\" name\=\"note\[spam\_answers\]\" type\=\"hidden\" value\=\"(.*)\" \/\>/
    html.must_match /\<input id\=\"note_spam_answer\" name\=\"note\[spam_answer\]\" type\=\"hidden\" value\=\"2\" \/\>/
  end
end
