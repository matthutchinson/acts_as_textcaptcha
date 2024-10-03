# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("#{File.dirname(__FILE__)}/../lib/acts_as_textcaptcha"))

# testing libs
require "minitest/autorun"
require "webmock/minitest"
require "./test/helpers/rails"
require "acts_as_textcaptcha"
require "./test/helpers/models"

# test helper methods

def clear_rails_log
  LOGGER_IO.truncate(0)
end

def assert_log_matches(lines)
  LOGGER_IO.rewind
  logged_lines = LOGGER_IO.readlines
  lines.each_with_index do |line, index|
    assert_match line, logged_lines[index]
  end
end

def find_in_cache(key)
  Rails.cache.read("#{ActsAsTextcaptcha::TextcaptchaCache::KEY_PREFIX}#{key}")
end

def stub_api_with(response_body, api_key: "api_key", api_endpoint: nil, http_status: 200)
  api_endpoint ||= "http://textcaptcha.com/#{api_key}.json"
  stub_request(:get, api_endpoint).to_return(
    status: http_status,
    body: response_body
  )
end

def valid_json_response
  json_response("single_answer.json")
end

def json_response(filename)
  fixture_dir = File.expand_path("#{File.dirname(__FILE__)}/fixtures/")
  File.read("#{fixture_dir}/responses/#{filename}")
end
