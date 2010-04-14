require File.join(File.dirname(__FILE__), 'test_helper')

class Widget < ActiveRecord::Base
  # uses textcaptcha.yml file for configuration
  acts_as_textcaptcha
end

class Comment < ActiveRecord::Base
  # uses inline options for configuration
  acts_as_textcaptcha({'api_key' => '8u5ixtdnq9csc84cok0owswgo'})
end

class Review < ActiveRecord::Base
  # uses inline options for configuration, including users own spam questions
  acts_as_textcaptcha({'api_key' => 'not going to work',
                       'questions' => [{'question' => '1+1', 'answers' => '2,two'},
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

  end

  describe "config" do

    it "should be configured from yml" do
      puts Widget.config.inspect
    end
  end

  describe "with textcaptcha api_key options" do

    it "should generate spam question" do
      @comment.generate_spam_question
      puts @comment.spam_question


    end

    describe "and textcaptcha unavailable" do
      it "should fall back to random user defined question" do
        @review.generate_spam_question
        puts @review.spam_question
      end
    end

  end

  describe "with textcaptcha yaml config file" do

    it "should generate spam question" do
      @widget.generate_spam_question
      puts @widget.spam_question
    end

    describe "and textcaptcha unavailable" do
      it "should fall back to a random user defined question" do
        @widget.generate_spam_question
        puts @widget.spam_question
      end
    end
  end
end