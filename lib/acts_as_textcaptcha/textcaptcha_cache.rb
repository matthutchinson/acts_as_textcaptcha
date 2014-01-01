# A simple cache for storing Textcaptcha answers
# by default the underlying cache implementation is
# the standard Rails.cache (ActiveSupport::Cache)

module ActsAsTextcaptcha
  class TextcaptchaCache

    CACHE_KEY_PREFIX = 'acts_as_textcaptcha-'
    DEFAULT_CACHE_EXPIRY_MINUTES = 10

    def write(key, value, options = {})
      unless options.has_key?(:expires_in)
        options[:expires_in] = DEFAULT_CACHE_EXPIRY_MINUTES.minutes
      end
      Rails.cache.write(cache_key(key), value, options)
    end

    def read(key, options = nil)
      Rails.cache.read(cache_key(key), options)
    end

    def delete(key, options = nil)
      Rails.cache.delete(cache_key(key), options)
    end

    private

    # since this cache may be shared with other objects
    # a prefix is used in all cache keys
    def cache_key(key)
      "#{CACHE_KEY_PREFIX}#{key}"
    end
  end
end
