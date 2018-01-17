require File.expand_path(File.dirname(__FILE__)+'/test_helper')

describe 'TextcaptchaApi' do

  describe 'with a valid xml response' do

    before(:each) do
      body = "<captcha><question>1+1?</question><answer>1</answer><answer>2</answer><answer>3</answer></captcha>"
      stub_request(:get, "http://textcaptcha.com/api/abc").to_return(:body => body)
    end

    it 'should fetch and parse an answer from the service' do
      result = ActsAsTextcaptcha::TextcaptchaApi.fetch('abc')
      result[0].must_equal '1+1?'
      result[1].must_equal ['1', '2', '3']
    end

    it 'should allow http options to be set' do
      result = ActsAsTextcaptcha::TextcaptchaApi.fetch('abc', { :http_read_timeout => 30,
                                                                :http_open_timeout => 5 })
      result.length.must_equal 2
    end
  end

  it 'should return nil when Net::HTTP errors occur' do
    [
      SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
      Errno::EHOSTUNREACH, EOFError, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
      Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
      URI::InvalidURIError
    ].each do |error|
       stub_request(:get, "http://textcaptcha.com/api/xyz").to_raise(error)
       assert_nil ActsAsTextcaptcha::TextcaptchaApi.fetch('xyz')
     end
  end

  it 'should return nil when body cannot be parsed as XML' do
    stub_request(:get, "http://textcaptcha.com/api/jibber").to_return(:body => 'here be gibberish')
    assert_nil ActsAsTextcaptcha::TextcaptchaApi.fetch('jibber')
  end

  it 'should return nil when body is empty' do
    stub_request(:get, "http://textcaptcha.com/api/empty").to_return(:body => '')
    assert_nil ActsAsTextcaptcha::TextcaptchaApi.fetch('empty')
  end
end
