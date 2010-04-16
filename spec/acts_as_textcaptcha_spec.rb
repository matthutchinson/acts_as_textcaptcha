require File.join(File.dirname(__FILE__), 'test_helper')

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


describe "ActsAsTextcaptcha" do

  before(:each) do
    @widget  = Widget.new
    @comment = Comment.new
    @review  = Review.new
  end

  describe "validations" do

    it "should validate spam answer with possible answers" do

    end

    it "should strip whitespace and downcase spam answer" do

    end
  end

  describe "encryption" do

    it "should encrypt answers" do

    end

    it "should encrypt a single answer" do

    end
  end

  describe "flags" do

    it "should always be valid if skip_spam_check? is true" do

    end

    it "should always fail validation if allowed? is false" do

    end
  end

  describe "with inline options hash" do

    it "should be configurable from inline options" do
      #puts Review.config.inspect
    end

    it "should be configurable with only an api_key" do
      #puts Comment.config.inspect
    end

    it "should generate spam question" do
      @comment.generate_spam_question
      #puts @comment.spam_question
    end

    describe "and textcaptcha unavailable" do

      it "should fall back to random user defined question when set" do
        @review.generate_spam_question
        #puts @review.spam_question
      end

      it "should not generate any spam question/answer if no user defined questions set" do
        @comment.generate_spam_question
        #puts @comment.spam_question
      end
    end
  end

  describe "with textcaptcha yaml config file" do

    it "should be configurable from config/textcaptcha.yml file" do
      #puts Widget.config.inspect
    end

    it "should generate spam question" do
      @widget.generate_spam_question
      #puts @widget.spam_question
    end

    describe "and textcaptcha unavailable" do
      it "should fall back to a random user defined question" do
        @widget.generate_spam_question
        #puts @widget.spam_question
      end
    end
  end
end