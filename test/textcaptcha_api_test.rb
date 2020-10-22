# frozen_string_literal: true

require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class ActsAsTextcaptcha::TextcaptchaApiTest < Minitest::Test
  def test_raises_error_for_invalid_api_key
    bad_key = "x b a d"
    error = assert_raises(ActsAsTextcaptcha::ApiKeyError) do
      textcaptcha_api(api_key: bad_key).fetch
    end
    assert_match(/^Api key '#{bad_key}' is invalid/, error.message)
  end

  def test_fetch_and_parse_q_and_a
    stub_api_with(valid_json_response)
    q_and_a = textcaptcha_api.fetch
    assert_equal q_and_a["q"], "What is Jennifer\'s name?"
    assert_equal q_and_a["a"], ["1660fe5c81c4ce64a2611494c439e1ba"]
  end

  def test_fetch_and_parse_q_and_a_from_defined_endpoint
    my_api_endpoint = "http://myserver.com/my-api.json"
    stub_api_with(valid_json_response, api_endpoint: my_api_endpoint)
    q_and_a = textcaptcha_api(api_endpoint: my_api_endpoint).fetch
    assert_equal q_and_a["q"], "What is Jennifer\'s name?"
    assert_equal q_and_a["a"], ["1660fe5c81c4ce64a2611494c439e1ba"]
  end

  def test_returns_nil_when_net_http_errors
    [
      SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
      Errno::EHOSTUNREACH, EOFError, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
      Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
    ].each do |error|
      stub_request(:get, %r{http://textcaptcha.com}).to_raise(error)
      assert_nil textcaptcha_api.fetch
    end
  end

  def test_returns_nil_when_non_200_response_code_received
    stub_api_with("", http_status: 302)
    assert_nil textcaptcha_api.fetch
  end

  def test_returns_nil_when_json_parsing_error
    stub_api_with("here be gibberish")
    assert_nil textcaptcha_api.fetch
  end

  def test_logs_error_to_rails_logger_if_raise_errors_not_set
    clear_rails_log
    stub_request(:get, %r{http://textcaptcha.com}).to_raise(Timeout::Error)
    textcaptcha_api(raise_errors: false).fetch
    assert_log_matches [/ActsAsTextcaptcha::ResponseError fetching '.*' failed - Exception from WebMock/]
  end

  def test_returns_nil_when_empty_response_received
    stub_api_with("")
    assert_nil textcaptcha_api.fetch
  end

  def test_raises_response_error_if_raise_errors_set
    stub_request(:get, %r{http://textcaptcha.com}).to_raise(Timeout::Error)
    error = assert_raises(ActsAsTextcaptcha::ResponseError) do
      textcaptcha_api(raise_errors: true).fetch
    end
    assert_match(/^fetching '.*' failed - Exception from WebMock/, error.message)
  end

  def test_raises_parse_error_if_raise_errors_set
    stub_api_with("here be gibberish")
    error = assert_raises(ActsAsTextcaptcha::ParseError) do
      textcaptcha_api(raise_errors: true).fetch
    end
    assert_match(/^parsing JSON from '.*' failed/, error.message)
  end

  private

  def textcaptcha_api(api_key: "api_key", api_endpoint: nil, raise_errors: false)
    @textcaptcha_api ||= ActsAsTextcaptcha::TextcaptchaApi.new(
      api_key: api_key,
      api_endpoint: api_endpoint,
      raise_errors: raise_errors
    )
  end
end
