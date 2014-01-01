# simple wrapper for the textcaptcha.com API service
# loads and parses captcha question and answers

require 'rexml/document'

module ActsAsTextcaptcha

  # raised if an empty response is returned
  class EmptyResponseError < StandardError; end;

  class TextcaptchaApi

    ENDPOINT = 'http://textcaptcha.com/api/'

    def self.fetch(api_key, options = {})
      begin
        url = uri_parser.parse("#{ENDPOINT}#{api_key}")
        http = Net::HTTP.new(url.host, url.port)
        if options[:http_open_timeout]
          http.open_timeout = options[:http_open_timeout]
        end
        if options[:http_read_timeout]
          http.read_timeout = options[:http_read_timeout]
        end

        response = http.get(url.path)
        if response.body.empty?
          raise ActsAsTextcaptcha::EmptyResponseError
        else
          return parse(response.body)
        end
      rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
        Errno::EHOSTUNREACH, EOFError, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
        URI::InvalidURIError, ActsAsTextcaptcha::EmptyResponseError,
        REXML::ParseException
        # rescue from these errors and continue
      end
    end

    def self.parse(xml)
      parsed_xml = ActiveSupport::XmlMini.parse(xml)['captcha']
      question = parsed_xml['question']['__content__']
      if parsed_xml['answer'].is_a?(Array)
        answers = parsed_xml['answer'].collect { |a| a['__content__'] }
      else
        answers = [parsed_xml['answer']['__content__']]
      end

      [question, answers]
    end


    private

    def self.uri_parser
      # URI.parse is deprecated in 1.9.2
      URI.const_defined?(:Parser) ? URI::Parser.new : URI
    end
  end
end
