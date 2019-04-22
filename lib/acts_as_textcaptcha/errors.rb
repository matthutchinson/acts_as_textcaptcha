# frozen_string_literal: true

module ActsAsTextcaptcha
  class ResponseError < StandardError
    def initialize(url, exception)
      super("fetching '#{url}' failed - #{exception}")
    end
  end

  class ApiKeyError < StandardError
    def initialize(api_key, exception)
      super("Api key '#{api_key}' is invalid - #{exception}")
    end
  end

  class ParseError < StandardError
    def initialize(url)
      super("parsing JSON from '#{url}' failed")
    end
  end
end
