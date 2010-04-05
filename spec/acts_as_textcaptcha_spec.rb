require File.join(File.dirname(__FILE__), 'test_helper')

class Comment < ActiveRecord::Base
  acts_as_textcaptcha
end

describe "ActsAsTextcaptcha" do

  before do
    sql = ActiveRecord::Base.connection();
  end

  after do
    Comment.delete_all
  end

  before(:each) do
    @comment = Comment.new
  end

  describe "validations" do

  end

  describe "with textcaptcha api" do

    it "should generate spam question" do
      @comment.generate_spam_question
      puts @comment.spam_question

    end



  end

  describe "without textcaptcha api" do

    it "should fall back to random config question" do

    end
  end

end