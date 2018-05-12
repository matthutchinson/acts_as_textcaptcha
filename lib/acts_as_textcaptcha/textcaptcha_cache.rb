# A simple cache for storing Textcaptcha answers, Rails.cache is used as the
# backend (ActiveSupport::Cache)

module ActsAsTextcaptcha
  class TextcaptchaCache

    KEY_PREFIX = 'acts_as_textcaptcha-'
    DEFAULT_EXPIRY_MINUTES = 10

    def write(key, value, options = {})
      unless options.has_key?(:expires_in)
        options[:expires_in] = DEFAULT_EXPIRY_MINUTES.minutes
      end
      Rails.cache.write(cache_key(key), value, options)
    end

    def read(key)
      Rails.cache.read(cache_key(key))
    end

    def delete(key)
      Rails.cache.delete(cache_key(key))
    end

    private

      def cache_key(key)
        "#{KEY_PREFIX}#{key}"
      end
  end
end
