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
  
  it "does something"
  
  
end