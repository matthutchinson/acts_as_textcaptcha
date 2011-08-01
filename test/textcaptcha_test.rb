require 'minitest/autorun'
require 'minitest/spec'
require 'redgreen'

class TestReddit < MiniTest::Unit::TestCase
  def setup
    @one = 1
  end

  def test_hot_story
    assert_equal @one, 1
  end
end

describe 'Something' do
  before do
    @two = 2
  end

  describe "when doing something" do
    it "should return two" do
      @two.must_equal 2
    end
  end
end
