# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class ActsAsTextcaptcha::TextcaptchaCacheTest < Minitest::Test

  def setup
    cache.write('mykey', [1,2,3])
  end

  def test_reading_from_cache
    assert_equal cache.read('mykey'), [1,2,3]
  end

  def test_writing_to_cache
    cache.write('my-new-key', 'abc')
    assert_equal cache.read('my-new-key'), 'abc'
  end

  def test_deleting_from_cache
    assert_equal cache.read('mykey'), [1,2,3]
    cache.delete('mykey')

    assert_nil cache.read('mykey')
  end

  def test_cache_keys_use_a_prefix
    assert_equal Rails.cache.read("#{ActsAsTextcaptcha::TextcaptchaCache::KEY_PREFIX}mykey"), [1,2,3]
  end

  private

    def cache
      @cache ||= ActsAsTextcaptcha::TextcaptchaCache.new
    end
end
