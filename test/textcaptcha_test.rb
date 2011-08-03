require_relative 'test_helper'

class Widget < ActiveRecord::Base
  # uses textcaptcha.yml file for configuration
  acts_as_textcaptcha
end

class Comment < ActiveRecord::Base
  # inline options with api_key only
  acts_as_textcaptcha 'api_key'     => '8u5ixtdnq9csc84cok0owswgo',
                      'bcrypt_salt' => '$2a$10$j0bmycH.SVfD1b5mpEGPpe'
end

class Review < ActiveRecord::Base
  # inline options with all possible options
  acts_as_textcaptcha  'api_key'     => '8u5ixtdnq9csc84cok0owswgo',
                       'bcrypt_salt' => '$2a$10$j0bmycH.SVfD1b5mpEGPpe',
                       'bcrypt_cost' => '3',
                       'questions'   => [{'question' => 'The green hat is what color?', 'answers' => 'green'}]
end

class Note < ActiveRecord::Base
  # inline options (string keys) with user defined questions only (no textcaptcha service)
  acts_as_textcaptcha 'questions'   => [{'question' => '1+1', 'answers' => '2,two'}],
                      'bcrypt_salt' => '$2a$10$j0bmycH.SVfD1b5mpEGPpe'

  attr_accessor :turn_off_captcha

  def perform_textcaptcha?
    !turn_off_captcha
  end
end

class Contact
  # non active record object (symbol keys)
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActsAsTextcaptcha::Textcaptcha
  acts_as_textcaptcha :questions   => [{:question => 'one+1', :answers => '2,two'}],
                      :bcrypt_salt => '$2a$10$j0bmycH.SVfD1b5mpEGPpe'
end


describe 'Textcaptcha' do

  describe 'validations' do

    before(:each) do
      @note = Note.new
      @note.textcaptcha
    end

    it 'should validate an ActiveRecord object (with multiple correct answers)' do
      @note.spam_question.must_equal('1+1')
      @note.valid?.must_equal false
      @note.errors[:spam_answer].first.must_equal('is incorrect, try another question instead')

      @note.spam_answer = 'two'
      @note.valid?.must_equal true
      @note.errors[:spam_answer].must_be_empty

      @note.spam_answer = '2'
      @note.valid?.must_equal true
      @note.errors[:spam_answer].must_be_empty
    end

    it 'should strip whitespace and downcase spam answer' do
      @note.spam_answer = ' tWo '
      @note.valid?.must_equal true
      @note.errors[:spam_answer].must_be_empty
    end

    it 'should always be valid when record has been saved' do
      @note.spam_answer = '2'
      @note.save!
      @note.textcaptcha

      @note.spam_answer = 'wrong answer'
      @note.new_record?.must_equal false
      @note.valid?.must_equal true
      @note.errors[:spam_answer].must_be_empty
    end

    it 'should always be valid when perform_textcaptcha? is false' do
      @note.turn_off_captcha = true
      @note.valid?.must_equal true
      @note.errors[:spam_answer].must_be_empty

      @note.save.must_equal true
    end

    it "should validate a non ActiveRecord object" do
      @contact = Contact.new
      @contact.textcaptcha

      @contact.spam_question.must_equal('one+1')
      @contact.spam_answer = 'wrong'
      @contact.valid?.must_equal false

      @contact.spam_answer = 'two'
      @contact.valid?.must_equal true
      @contact.errors[:spam_answer].must_be_empty
    end
  end

  describe 'encryption' do

    it 'should encrypt spam_answers (joined by - seperator) MD5 digested and using BCrypt engine with salt' do
      @note = Note.new
      @note.spam_answers.must_be_nil
      @note.textcaptcha
      encrypted_answers = [2,' TwO '].collect { |answer| BCrypt::Engine.hash_secret(Digest::MD5.hexdigest(answer.to_s.strip.downcase), '$2a$10$j0bmycH.SVfD1b5mpEGPpe', 1) }.join('-')
      @note.spam_answers.must_equal("$2a$10$j0bmycH.SVfD1b5mpEGPpePFe1wBxOn7Brr9lMuLRxv6lg4ZYjJ22-$2a$10$j0bmycH.SVfD1b5mpEGPpe8v5mqqpDaExuS/hZu8Xkq8krYL/T8P.")
      @note.spam_answers.must_equal(encrypted_answers)
    end
  end

  describe 'textcaptcha API service' do

    it 'should generate spam question from textcaptcha service' do
      @comment = Comment.new
      @comment.textcaptcha
      @comment.spam_question.wont_be_nil
      @comment.spam_answers.wont_be_nil

      @comment.valid?.must_equal false
      @comment.errors[:spam_answer].first.must_equal('is incorrect, try another question instead')
    end

    describe 'and textcaptcha unavailable' do

      before(:each) do
        @review = Review.new
      end

      after(:each) do
        FakeWeb.clean_registry
      end

      it 'should fall back to a random user defined question when NET error and at least one fallback question is defined' do
        FakeWeb.register_uri(:get, %r|http://textcaptcha\.com/api/|, :status => ['401', 'Not Found'])

        @review.textcaptcha
        @review.spam_question.must_equal('The green hat is what color?')
        @review.spam_answers.wont_be_nil
      end

      #it 'should not generate any spam question/answer if no user defined questions set' do
        #@comment.generate_spam_question
        #@comment.spam_question.should be_nil
        #@comment.possible_answers.should be_nil
        #@comment.validate_textcaptcha.should be_true
        #@comment.should be_valid
      #end
    end

  end

end
