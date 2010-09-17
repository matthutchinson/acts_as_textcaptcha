require 'spec_helper'

class Widget < ActiveRecord::Base
  # uses textcaptcha.yml file for configuration
  acts_as_textcaptcha
end

class Comment < ActiveRecord::Base
  # inline options with api_key only
  acts_as_textcaptcha({'api_key' => '8u5ixtdnq9csc84cok0owswgo'})
end

class Review < ActiveRecord::Base
  # inline options with all possible options
  acts_as_textcaptcha({'api_key'     => '8u5ixtdnq9csc84cok0owswgo',
                       'bcrypt_salt' => '$2a$10$j0bmycH.SVfD1b5mpEGPpe',
                       'bcrypt_cost' => '3',
                       'questions'   => [{'question' => '1+1', 'answers' => '2,two'},
                                         {'question' => 'The green hat is what color?', 'answers' => 'green'},
                                         {'question' => 'Which is bigger: 67, 14 or 6', 'answers' => '67,sixtyseven,sixty seven,sixty-seven'}]})
end

class Note < ActiveRecord::Base
  # inline options with user defined questions only (no textcaptcha service)
  acts_as_textcaptcha('questions' => [{'question' => '1+1', 'answers' => '2,two'}])
end  

class Contact
  # non active record object         
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActsAsTextcaptcha::Textcaptcha 
  acts_as_textcaptcha('questions' => [{'question' => '1+1', 'answers' => '2,two'}]) 
end


describe 'ActsAsTextcaptcha' do

  before(:each) do
    @comment = Comment.new
    @review  = Review.new
    @note    = Note.new   
    @contact = Contact.new 
  end

  describe 'validations' do

    before(:each) do
      @note.generate_spam_question
      @note.validate_textcaptcha.should be_false
      @note.should_not be_valid
    end  
    
    it "should validate non ActiveRecord object" do
      @contact.generate_spam_question
      @contact.spam_answer = 'wrong'
      @contact.validate_textcaptcha.should be_false
      @contact.should_not be_valid
      
      @contact.spam_answer = 'two'
      @contact.validate_textcaptcha.should be_true
      @contact.should be_valid
    end

    it 'should validate spam answer with possible answers' do
      @note.spam_answer = '2'
      @note.validate_textcaptcha.should be_true
      @note.should be_valid

      @note.spam_answer = 'two'
      @note.validate_textcaptcha.should be_true
      @note.should be_valid

      @note.spam_answer = 'wrong'
      @note.validate_textcaptcha.should be_false
      @note.should_not be_valid
    end

    it 'should strip whitespace and downcase spam answer' do
      @note.spam_answer = ' tWo '
      @note.validate_textcaptcha.should be_true
      @note.should be_valid

      @note.spam_answer = ' 2   '
      @note.validate_textcaptcha.should be_true
      @note.should be_valid
    end

    it 'should always validate if not a new record' do
      @note.spam_answer = '2'
      @note.save!
      @note.generate_spam_question

      @note.new_record?.should be_false
      @note.validate_textcaptcha.should be_true
      @note.should be_valid
    end
  end

  describe 'encryption' do

    it 'should encrypt answers' do
      @review.encrypt_answers(['123', '456']).should eql(['$2a$10$j0bmycH.SVfD1b5mpEGPperNj9IlIHoieNk38UDQFdtREOmRFKgou',
                                                          '$2a$10$j0bmycH.SVfD1b5mpEGPpeqf88jqdV6gIgeJLQNjUnufIn8dys1fW'])
    end

    it 'should encrypt a single answer' do
      @review.encrypt_answer('123').should eql('$2a$10$j0bmycH.SVfD1b5mpEGPperNj9IlIHoieNk38UDQFdtREOmRFKgou')
    end

    it 'should not encrypt if no bycrpt-salt set' do
      @comment.encrypt_answer('123').should eql('123')
      @comment.encrypt_answers(['123', '456']).should eql(['123', '456'])
    end
  end

  describe 'flags' do

    it 'should always be valid if skip_spam_check? is true' do
      @comment.generate_spam_question
      @comment.validate_textcaptcha.should be_false
      @comment.should_not be_valid

      @comment.stub!(:perform_spam_check?).and_return(false)
      @comment.validate_textcaptcha.should be_true
      @comment.should be_valid
    end

    it 'should always fail validation if allowed? is false' do
      @comment.validate_textcaptcha.should be_true
      @comment.stub!(:allowed?).and_return(false)

      @comment.validate_textcaptcha.should be_false
      @comment.errors[:base].should eql(['Sorry, comments are currently disabled'])
      @comment.should_not be_valid
    end
  end

  describe 'with inline options hash' do

    it 'should be configurable from inline options' do
      @comment.textcaptcha_config.should eql({'api_key' => '8u5ixtdnq9csc84cok0owswgo'})
      @review.textcaptcha_config.should  eql({'bcrypt_cost'=>'3', 'questions'=>[{'question'=>'1+1', 'answers'=>'2,two'},
                                                                                {'question'=>'The green hat is what color?', 'answers'=>'green'},
                                                                                {'question'=>'Which is bigger: 67, 14 or 6', 'answers'=>'67,sixtyseven,sixty seven,sixty-seven'}],
                                                                  'bcrypt_salt'=>'$2a$10$j0bmycH.SVfD1b5mpEGPpe', 'api_key'=>'8u5ixtdnq9csc84cok0owswgo'})
      @note.textcaptcha_config.should    eql({'questions'=>[{'question'=>'1+1', 'answers'=>'2,two'}]})
    end

    it 'should generate spam question from textcaptcha service' do
      @comment.generate_spam_question
      @comment.spam_question.should_not be_nil
      @comment.possible_answers.should_not be_nil
      @comment.possible_answers.should be_an(Array)

      @comment.validate_textcaptcha.should be_false
      @comment.should_not be_valid
    end

    describe 'and textcaptcha unavailable' do

      before(:each) do
        Net::HTTP.stub(:get).and_raise(SocketError)
      end

      it 'should fall back to random user defined question when set' do
        @review.generate_spam_question
        @review.spam_question.should_not be_nil
        @review.possible_answers.should_not be_nil
        @review.possible_answers.should be_an(Array)

        @review.validate_textcaptcha.should be_false
        @review.should_not be_valid
      end

      it 'should not generate any spam question/answer if no user defined questions set' do
        @comment.generate_spam_question
        @comment.spam_question.should be_nil
        @comment.possible_answers.should be_nil
        @comment.validate_textcaptcha.should be_true
        @comment.should be_valid
      end
    end
  end

  describe 'with textcaptcha yaml config file' do

    before(:each) do
      @widget = Widget.new
    end

    it 'should be configurable from config/textcaptcha.yml file' do
      @widget.textcaptcha_config['api_key'].should eql('8u5ixtdnq9csc84cok0owswgo')
      @widget.textcaptcha_config['bcrypt_salt'].should eql('$2a$10$j0bmycH.SVfD1b5mpEGPpe')
      @widget.textcaptcha_config['bcrypt_cost'].should eql(10)
      @widget.textcaptcha_config['questions'].length.should eql(10)
    end

    it 'should generate spam question' do
      @widget.generate_spam_question
      @widget.spam_question.should_not be_nil
      @widget.possible_answers.should_not be_nil
      @widget.possible_answers.should be_an(Array)
      @widget.validate_textcaptcha.should be_false
      @widget.should_not be_valid
    end

    describe 'and textcaptcha unavailable' do

      before(:each) do
        Net::HTTP.stub(:get).and_raise(SocketError)
      end

      it 'should fall back to a random user defined question' do
        @widget.generate_spam_question
        @widget.spam_question.should_not be_nil
        @widget.possible_answers.should_not be_nil
        @widget.possible_answers.should be_an(Array)
        @widget.validate_textcaptcha.should be_false
        @widget.should_not be_valid
      end
    end
  end
end