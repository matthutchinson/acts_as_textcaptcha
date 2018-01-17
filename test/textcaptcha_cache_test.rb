require File.expand_path(File.dirname(__FILE__)+'/test_helper')

describe 'TextcaptchaCache' do

  before(:each) do
    @cache = ActsAsTextcaptcha::TextcaptchaCache.new
    @cache.write('mykey', [1,2,3])
  end

  it 'should write to the cache' do
    @cache.write('my-new-key', 'abc')
    @cache.read('my-new-key').must_equal 'abc'
  end

  it 'should read from the cache' do
    @cache.read('mykey').must_equal [1,2,3]
  end

  it 'should delete from the cache' do
    @cache.read('mykey').must_equal [1,2,3]
    @cache.delete('mykey')

    assert_nil @cache.read('mykey')
  end
end
