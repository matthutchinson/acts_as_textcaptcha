# frozen_string_literal: true

require "json"

module ActsAsTextcaptcha
  class TextcaptchaApi
    BASE_URL = "http://textcaptcha.com"

    def initialize(api_key: nil, api_endpoint: nil, raise_errors: false)
      self.uri = URI(api_endpoint || "#{BASE_URL}/#{api_key}.json")

      self.raise_errors = raise_errors || false
    rescue URI::InvalidURIError => e
      raise ApiKeyError.new(api_key, e)
    end

    def fetch
      parse(get.to_s)
    end

    private

    attr_accessor :uri, :raise_errors

    def get
      response = Net::HTTP.new(uri.host, uri.port).get(uri.path)
      if response.code == "200"
        response.body
      else
        handle_error ResponseError.new(uri, "status: #{response.code}")
      end
    rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
           Errno::EHOSTUNREACH, EOFError, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
           Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
           Net::ProtocolError => e
      handle_error ResponseError.new(uri, e)
    end

    def parse(response)
      JSON.parse(response) unless response.empty?
    rescue JSON::ParserError
      handle_error ParseError.new(uri)
    end

    def handle_error(error)
      raise error if raise_errors

      Rails.logger.error("#{error.class} #{error.message}")
      nil
    end
  end
end
